import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chapur_ia/presentation/blocs/order/order_bloc.dart';
import 'package:chapur_ia/domain/entities/order.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(const FetchOrdersRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is OrderFailure) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is OrderListLoaded) {
          if (state.orders.isEmpty) {
            return const Center(child: Text('No tienes pedidos registrados.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = state.orders[index];
              return _OrderListItem(order: order);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _OrderListItem extends StatelessWidget {
  final Order order;
  const _OrderListItem({required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              order.legacyOrderId,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            _buildStatusChip(order.status),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Fecha: ${dateFormat.format(order.date)}'),
            Text('Cliente: ${order.customerName}'),
            const SizedBox(height: 8),
            Text(
              '\$${order.total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF6366F1),
                fontSize: 16,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Order details view
        },
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'submitted':
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'dispatched':
      case 'delivered':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
