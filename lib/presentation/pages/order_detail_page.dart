import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/order/order_bloc.dart';
import '../../injection_container.dart' as di;
import '../../domain/entities/order.dart';

class OrderDetailPage extends StatefulWidget {
  final Order order;

  const OrderDetailPage({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late OrderBloc _orderBloc;

  @override
  void initState() {
    super.initState();
    // Use a fresh instance of OrderBloc to avoid overriding the list in the global scope
    _orderBloc = di.sl<OrderBloc>()..add(FetchOrderDetailRequested(widget.order.id));
  }

  @override
  void dispose() {
    _orderBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _orderBloc,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          title: const Text('Detalle de Pedido'),
          backgroundColor: const Color(0xFF1A1F2C),
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            Order displayOrder = widget.order;
            bool isLoading = state is OrderLoading || state is OrderInitial;

            if (state is OrderDetailLoaded) {
              displayOrder = Order(
                id: displayOrder.id,
                orderNumber: state.order.orderNumber.isNotEmpty ? state.order.orderNumber : displayOrder.orderNumber,
                legacyOrderId: state.order.legacyOrderId.isNotEmpty ? state.order.legacyOrderId : displayOrder.legacyOrderId,
                customerAccountNumber: state.order.customerAccountNumber.isNotEmpty ? state.order.customerAccountNumber : displayOrder.customerAccountNumber,
                customerName: state.order.customerName.isNotEmpty ? state.order.customerName : displayOrder.customerName,
                date: state.order.date,
                status: state.order.status.isNotEmpty ? state.order.status : displayOrder.status,
                total: state.order.total > 0 ? state.order.total : displayOrder.total,
                items: state.order.items.isNotEmpty ? state.order.items : displayOrder.items,
              );
            }

            if (state is OrderFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _orderBloc.add(FetchOrderDetailRequested(widget.order.id));
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                _buildDetail(displayOrder),
                if (isLoading)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetail(Order order) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pedido ${order.legacyOrderId.isNotEmpty ? order.legacyOrderId : order.orderNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      _buildStatusChip(order.status),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildInfoRow('Fecha:', dateFormat.format(order.date)),
                  _buildInfoRow('Cliente:', order.customerName),
                  _buildInfoRow('Nº Cuenta:', order.customerAccountNumber),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Artículos',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...order.items.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(item.description, style: const TextStyle(fontSize: 14)),
                  subtitle: Text('Cód: ${item.articleCode}  •  Cant: ${item.quantity}', style: const TextStyle(fontSize: 12)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(currencyFormat.format(item.unitPrice), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        currencyFormat.format(item.subtotal),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    currencyFormat.format(order.total),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF6366F1)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
