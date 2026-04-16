import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chapur_ia/presentation/blocs/account/account_bloc.dart';
import 'package:chapur_ia/presentation/blocs/auth/auth_bloc.dart';

class AccountSummaryPage extends StatefulWidget {
  const AccountSummaryPage({super.key});

  @override
  State<AccountSummaryPage> createState() => _AccountSummaryPageState();
}

class _AccountSummaryPageState extends State<AccountSummaryPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated && authState.user.customerAccountNumber != null) {
      context.read<AccountBloc>().add(FetchAccountSummaryRequested(
            accountNumber: authState.user.customerAccountNumber!,
            fechaDesde: DateTime.now().subtract(const Duration(days: 90)),
            fechaHasta: DateTime.now(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        if (state is AccountLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AccountFailure) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is AccountSummaryLoaded) {
          final summary = state.summary;
          final List<dynamic> items = summary['items'] ?? [];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(summary),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      return _MovementItem(item: item);
                    },
                    childCount: items.length,
                  ),
                ),
              ),
            ],
          );
        }
        return const Center(child: Text('Selecciona un cliente para ver su estado de cuenta.'));
      },
    );
  }

  Widget _buildHeader(Map<String, dynamic> summary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F2C),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'SALDO ACTUAL',
            style: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${(summary['saldoFinal'] as num).toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBalanceDetail('DEBE', summary['totalDebe'], Colors.redAccent),
              _buildBalanceDetail('HABER', summary['totalHaber'], Colors.greenAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceDetail(String title, num value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}

class _MovementItem extends StatelessWidget {
  final Map<String, dynamic> item;
  const _MovementItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isHaber = (item['haber'] as num) > 0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          isHaber ? Icons.arrow_downward : Icons.arrow_upward,
          color: isHaber ? Colors.green : Colors.redAccent,
        ),
        title: Text(
          item['descripcion'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          'Fecha: ${item['fecha']} | Exp: ${item['vencimiento'] ?? '-'}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${(isHaber ? item['haber'] : item['debe'] as num).toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isHaber ? Colors.green : Colors.redAccent,
              ),
            ),
            Text(
              'Saldo: \$${(item['saldo'] as num).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
