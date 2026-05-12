import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/account_summary.dart';
import '../../domain/entities/account_movement.dart';
import '../blocs/account/account_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import 'document_detail_page.dart';
import 'dashboard_page.dart';
import '../../injection_container.dart';
import '../widgets/custom_bottom_nav.dart';

class AccountSummaryPage extends StatefulWidget {
  final Customer? customer;
  final bool showAppBar;

  const AccountSummaryPage({super.key, this.customer, this.showAppBar = true});

  @override
  State<AccountSummaryPage> createState() => _AccountSummaryPageState();
}

class _AccountSummaryPageState extends State<AccountSummaryPage> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _soloPendientes = false;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  void _fetchSummary() {
    final customerAccountNumber = widget.customer?.accountNumber;
    if (customerAccountNumber != null) {
      context.read<AccountBloc>().add(FetchAccountSummaryRequested(
            accountNumber: customerAccountNumber,
            startDate: _startDate,
            endDate: _endDate,
            soloPendientes: _soloPendientes ? 1 : 0,
          ));
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated && authState.user.customerAccountNumber != null) {
      context.read<AccountBloc>().add(FetchAccountSummaryRequested(
            accountNumber: authState.user.customerAccountNumber!,
            startDate: _startDate,
            endDate: _endDate,
            soloPendientes: _soloPendientes ? 1 : 0,
          ));
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _fetchSummary();
    }
  }

  void _onDownloadPdf(AccountMovement movement) {
    context.read<AccountBloc>().add(DownloadDocumentPdfRequested(
          documentCode: movement.codigoCompro,
          documentNumber: movement.numeroCompro,
        ));
  }

  void _onVisualizeDetail(AccountMovement movement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<AccountBloc>(),
          child: DocumentDetailPage(
            documentCode: movement.codigoCompro,
            documentNumber: movement.numeroCompro,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: widget.showAppBar ? AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cuenta Corriente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            if (widget.customer != null)
              Text(
                widget.customer!.name,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
          ],
        ),
        backgroundColor: const Color(0xFF474747),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ) : null,
      body: BlocListener<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state is DocumentPdfLoaded) {
            Share.shareXFiles([XFile(state.filePath)], text: 'Comprobante PDF');
          } else if (state is AccountFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: Column(
          children: [
            _buildDateFilters(),
            Expanded(
              child: BlocBuilder<AccountBloc, AccountState>(
                builder: (context, state) {
                  if (state is AccountSummaryLoaded) {
                    return _buildContent(state.summary);
                  } else if (state is AccountLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is AccountInitial) {
                    return const Center(child: Text('No hay datos disponibles'));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: 0,
        onItemSelected: (index) {
          if (index == 3) { // Salir
            context.read<AuthBloc>().add(LogoutRequested());
            Navigator.popUntil(context, (route) => route.isFirst);
            return;
          }
          
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => DashboardPage(initialIndex: index)),
            (route) => false,
          );
        },
      ),
    );
  }

  Widget _buildDateFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DateSelector(
                  label: 'Desde',
                  date: _startDate,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DateSelector(
                  label: 'Hasta',
                  date: _endDate,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _soloPendientes,
                onChanged: (value) {
                  setState(() {
                    _soloPendientes = value ?? false;
                  });
                  _fetchSummary();
                },
                activeColor: const Color(0xFF5F5F5F),
              ),
              const Text(
                'Solo comprobantes pendientes',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5F5F5F),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AccountSummary summary) {
    return RefreshIndicator(
      onRefresh: () async => _fetchSummary(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildTotalizers(summary),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: _SectionHeader(title: 'MOVIMIENTOS'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _MovementCard(
                    movement: summary.movements[index],
                    onVisualize: () => _onVisualizeDetail(summary.movements[index]),
                    onDownload: () => _onDownloadPdf(summary.movements[index]),
                  );
                },
                childCount: summary.movements.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildTotalizers(AccountSummary summary) {
    final currencyFormat = NumberFormat.currency(symbol: r'$ ', decimalDigits: 2);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Saldo Final
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF37A863),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saldo Final',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(summary.totalSaldo),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Vencido
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD41E24).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/images/alert_red.png', width: 16, height: 16, errorBuilder: (_, __, ___) => const Icon(Icons.warning, color: Color(0xFFD41E24), size: 16)),
                          const SizedBox(width: 8),
                          const Text(
                            'Vencido',
                            style: TextStyle(color: Color(0xFFD41E24), fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormat.format(summary.totalDebe),
                        style: const TextStyle(
                          color: Color(0xFFD41E24),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Haber
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF29B36).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Haber',
                        style: TextStyle(color: Color(0xFFFF8800), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyFormat.format(summary.totalHaber),
                        style: const TextStyle(
                          color: Color(0xFFFF8800),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateSelector({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12, 
            color: Color(0xFF818080), 
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(date),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFF474747)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF818080),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }
}

class _MovementCard extends StatelessWidget {
  final AccountMovement movement;
  final VoidCallback onVisualize;
  final VoidCallback onDownload;

  const _MovementCard({
    required this.movement,
    required this.onVisualize,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(symbol: r'$ ', decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Comprobante
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF474747),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${movement.codigoCompro} ${movement.numeroCompro}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildItemInfo('Fecha', dateFormat.format(movement.fecha))),
                    Expanded(child: _buildItemInfo('Vencimiento', dateFormat.format(movement.vto))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildItemInfo('DEBE', currencyFormat.format(movement.debeN))),
                    Expanded(child: _buildItemInfo('HABER', currencyFormat.format(movement.haberN))),
                    Expanded(child: _buildItemInfo('SALDO', currencyFormat.format(movement.saldoN), isBold: true)),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onVisualize,
                      icon: Image.asset('assets/images/eyes.png', width: 20, height: 20, errorBuilder: (_, __, ___) => const Icon(Icons.visibility, size: 20)),
                      label: const Text('Ver', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF474747)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: onDownload,
                      icon: const Icon(Icons.share, size: 18),
                      label: const Text('Compartir', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD61D26),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemInfo(String label, String value, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF818080), 
            fontSize: 10, 
            fontWeight: FontWeight.bold
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14, 
            color: Color(0xFF5F5F5F),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
