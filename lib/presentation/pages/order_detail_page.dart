import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      child: BlocBuilder<OrderBloc, OrderState>(
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

          return Scaffold(
            backgroundColor: const Color(0xFFF8F9FA),
            appBar: AppBar(
              backgroundColor: const Color(0xFF474747),
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text(
                displayOrder.orderNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            bottomNavigationBar: state is OrderFailure ? null : _buildFooter(displayOrder),
            body: state is OrderFailure
                ? _buildErrorState(state.message)
                : Stack(
                    children: [
                      _buildContent(displayOrder),
                      if (isLoading)
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDE535C)),
                          ),
                        ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _orderBloc.add(FetchOrderDetailRequested(widget.order.id));
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Order order) {
    final currencyFormat = NumberFormat.currency(symbol: r'$ ', decimalDigits: 2);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Customer Info Card ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
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
                const Text(
                  'Cliente',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF474747),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.customerName,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF4C4C4C),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Codigo', order.customerAccountNumber, const Color(0xFF5F5F5F)),
                const SizedBox(height: 8),
                _buildInfoRow('Fecha', dateFormat.format(order.date), const Color(0xFF474747)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // ─── Products Title ──────────────────────────────────────────────
          const Text(
            'PRODUCTOS',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF818080),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          // ─── Product Items ───────────────────────────────────────────────
          ...order.items.map((item) => _buildProductItem(item, currencyFormat)),

          const SizedBox(height: 100), // Space for fixed footer
        ],
      ),
    );
  }

  Widget _buildFooter(Order order) {
    final currencyFormat = NumberFormat.currency(symbol: r'$ ', decimalDigits: 2);
    final subtotal = order.total / 1.21;
    final iva = order.total - subtotal;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow('Subtotal', currencyFormat.format(subtotal), isLarge: true),
            const SizedBox(height: 8),
            _buildSummaryRow('IVA (21%)', currencyFormat.format(iva)),
            const Divider(height: 20),
            _buildSummaryRow(
              'Total', 
              currencyFormat.format(order.total), 
              isBold: true, 
              amountColor: const Color(0xFFDE535C)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color labelColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            color: labelColor,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            color: labelColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(OrderItem item, NumberFormat format) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Placeholder for product image matching the capture style
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) {
                debugPrint('Error loading order product image: $url - Error: $error');
                return const Icon(Icons.image_not_supported, color: Colors.grey, size: 24);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF565656),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.quantity} x ${format.format(item.unitPrice)}',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF474747),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            format.format(item.subtotal),
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFFDE535C),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isLarge = false, Color? amountColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            color: const Color(0xFF474747),
            fontSize: isLarge ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            color: amountColor ?? const Color(0xFF474747),
            fontSize: isLarge ? 18 : 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
