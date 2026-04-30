import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/account_summary.dart';
import '../../domain/entities/account_movement.dart';
import '../blocs/account/account_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import 'document_detail_page.dart';

class AccountSummaryPage extends StatefulWidget {
  final Customer? customer;

  const AccountSummaryPage({super.key, this.customer});

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
        builder: (_) => DocumentDetailPage(
          documentCode: movement.codigoCompro,
          documentNumber: movement.numeroCompro,
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado de Cuenta'),
        backgroundColor: const Color(0xFF1A1F2C),
        foregroundColor: Colors.white,
      ),
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
                  // Return content with current state data if available or initial message
                  if (state is AccountInitial) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text(
                            'Seleccione un cliente para ver su estado de cuenta.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  // If we are in another state but were previously loaded, we might want to keep the list
                  // But BLoC logic here is simple, so we just show loading or failure if not loaded.
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
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
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              setState(() {
                _soloPendientes = !_soloPendientes;
              });
              _fetchSummary();
            },
            child: Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _soloPendientes,
                    onChanged: (value) {
                      setState(() {
                        _soloPendientes = value ?? false;
                      });
                      _fetchSummary();
                    },
                    activeColor: const Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Solo comprobantes pendientes',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
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
            child: _buildTotalizer(summary),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final movement = summary.movements[index];
                  return _MovementCard(
                    movement: movement,
                    onVisualize: () => _onVisualizeDetail(movement),
                    onDownload: () => _onDownloadPdf(movement),
                  );
                },
                childCount: summary.movements.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalizer(AccountSummary summary) {
    final currencyFormat = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F2C), Color(0xFF2E3A59)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'SALDO FINAL',
            style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(summary.totalSaldo),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildTotalItem('DEBE', summary.totalDebe, Colors.redAccent),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildTotalItem('HABER', summary.totalHaber, Colors.greenAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalItem(String title, double value, Color color) {
    final currencyFormat = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
    return Expanded(
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            currencyFormat.format(value),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
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
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFF6366F1)),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy').format(date),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x1A6366F1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    movement.codigoCompro,
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  '#${movement.numeroCompro}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1F2C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (movement.contrato.isNotEmpty) ...[
              _buildDetailRow('Contrato', movement.contrato),
              const SizedBox(height: 4),
            ],
            Row(
              children: [
                Expanded(child: _buildDetailRow('Fecha', dateFormat.format(movement.fecha))),
                Expanded(child: _buildDetailRow('Vencimiento', dateFormat.format(movement.vto))),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmount('DEBE', movement.debeN, Colors.black87),
                _buildAmount('HABER', movement.haberN, Colors.black87),
                _buildAmount('SALDO', movement.saldoN, const Color(0xFF6366F1), isBold: true),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onVisualize,
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Ver'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onDownload,
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Compartir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1F2C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildAmount(String label, double value, Color color, {bool isBold = false}) {
    final currencyFormat = NumberFormat.currency(symbol: r'$', decimalDigits: 2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(
          currencyFormat.format(value),
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
