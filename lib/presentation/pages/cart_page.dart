import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/cart/cart_bloc.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        elevation: 0,
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CartFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<CartBloc>().add(LoadCartRequested()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (state is CartLoaded) {
            final cart = state.cart;
            if (cart.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text('Tu carrito está vacío', style: TextStyle(color: Colors.grey, fontSize: 18)),
                  ],
                ),
              );
            }

            return Column(
              children: [
                if (cart.customerName != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                    child: Text(
                      'Cliente: ${cart.customerName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(item.description ?? 'Producto', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Código: ${item.articleCode}', style: const TextStyle(fontSize: 12)),
                            Text('Cantidad: ${item.quantity} x \$${(item.unitPrice ?? 0).toStringAsFixed(2)}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${(item.subtotal ?? (item.quantity * (item.unitPrice ?? 0))).toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () {
                                context.read<CartBloc>().add(RemoveFromCartRequested(item.articleCode));
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSummaryRow('Subtotal', cart.subtotal),
                        const SizedBox(height: 8),
                        _buildSummaryRow('IVA Total', cart.ivaTotal),
                        const Divider(height: 24),
                        _buildSummaryRow('TOTAL', cart.grandTotal, isTotal: true),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Finalización de pedido próximamente')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('FINALIZAR PEDIDO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('Cargando carrito...'));
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey.shade600,
          ),
        ),
        Text(
          NumberFormat.currency(symbol: '\$').format(amount),
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.bold,
            color: isTotal ? const Color(0xFF6366F1) : Colors.black,
          ),
        ),
      ],
    );
  }
}
