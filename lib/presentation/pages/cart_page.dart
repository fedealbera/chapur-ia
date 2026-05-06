import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/cart/cart_bloc.dart';
import 'checkout_form_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // USD currency formatter
  final _usdFormat = NumberFormat.currency(locale: 'en_US', symbol: 'USD ');

  @override
  void initState() {
    super.initState();
    // Refresh cart every time the page is opened to reflect web-side changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartBloc>().add(LoadCartRequested());
    });
  }

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
                      final unitPriceUsd = item.priceUsd ?? 0.0;
                      final subtotalUsd = item.subtotalUsd ?? (item.quantity * unitPriceUsd);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          item.description ?? 'Producto',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Código: ${item.articleCode}', style: const TextStyle(fontSize: 12)),
                            Text(
                              'Cantidad: ${item.quantity} x ${_usdFormat.format(unitPriceUsd)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            if (item.ivaRate != null)
                              Text(
                                'IVA: ${item.ivaRate!.toStringAsFixed(1)}%  (${_usdFormat.format(item.ivaAmountUsd ?? 0.0)})',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _usdFormat.format(subtotalUsd),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6366F1), fontSize: 13),
                                ),
                              ],
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
                // ─── Totals panel ─────────────────────────────────────────
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
                        _buildSummaryRow('Subtotal', cart.subtotalUsd),
                        const SizedBox(height: 8),
                        _buildSummaryRow('IVA Total', cart.ivaTotalUsd),
                        const Divider(height: 24),
                        _buildSummaryRow('TOTAL', cart.grandTotalUsd, isTotal: true),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CheckoutFormPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_bag_outlined, size: 20),
                                SizedBox(width: 8),
                                Text('FINALIZAR PEDIDO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
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
          _usdFormat.format(amount),
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFF6366F1) : Colors.black,
          ),
        ),
      ],
    );
  }
}
