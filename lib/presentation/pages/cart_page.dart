import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:chapur_ia/domain/entities/cart_item.dart';
import '../blocs/cart/cart_bloc.dart';
import 'checkout_form_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // USD currency formatter - matching the catalog style
  final _usdFormat = NumberFormat.currency(symbol: 'USD ', decimalDigits: 2);

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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF474747),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            String customerName = '';
            if (state is CartLoaded) {
              customerName = state.cart.customerName ?? '';
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nuevo pedido',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                if (customerName.isNotEmpty)
                  Text(
                    customerName,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
              ],
            );
          },
        ),
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
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return _CartProductItem(
                        item: item,
                        usdFormat: _usdFormat,
                      );
                    },
                  ),
                ),
                // ─── Summary Section ──────────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8, bottom: 8),
                        child: Text(
                          'RESUMEN DEL PEDIDO',
                          style: TextStyle(
                            color: Color(0xFF818080),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                          children: [
                            _buildSummaryRow('Subtotal', cart.subtotalUsd),
                            const SizedBox(height: 12),
                            _buildSummaryRow('IVA (21%)', cart.ivaTotalUsd),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1, color: Color(0xFFF2F2F2)),
                            ),
                            _buildSummaryRow('Total', cart.grandTotalUsd, isTotal: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // ─── Bottom Button ────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 60,
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
                      backgroundColor: const Color(0xFFD61D26),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    child: const Text(
                      'Ejecutar pedido',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
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
            fontSize: 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: const Color(0xFF474747),
            fontFamily: 'Inter',
          ),
        ),
        Text(
          _usdFormat.format(amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isTotal ? const Color(0xFFDE535C) : const Color(0xFF474747),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

class _CartProductItem extends StatelessWidget {
  final CartItem item;
  final NumberFormat usdFormat;

  const _CartProductItem({
    required this.item,
    required this.usdFormat,
  });

  @override
  Widget build(BuildContext context) {
    final unitPrice = item.priceUsd ?? 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: CachedNetworkImage(
              imageUrl: item.imageUrl ?? '',
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) {
                debugPrint('Error loading cart product image: $url - Error: $error');
                return const Icon(Icons.image_not_supported, color: Colors.grey, size: 30);
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.description ?? 'Producto',
                        style: const TextStyle(
                          color: Color(0xFF565656),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.read<CartBloc>().add(RemoveFromCartRequested(item.articleCode));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.asset(
                          'assets/images/trash.png',
                          width: 24,
                          height: 24,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} x ${usdFormat.format(unitPrice)}',
                  style: const TextStyle(
                    color: Color(0xFF474747),
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      usdFormat.format(unitPrice),
                      style: const TextStyle(
                        color: Color(0xFFDE535C),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Inter',
                      ),
                    ),
                    Row(
                      children: [
                        _buildIconBtn(context, 'assets/images/less.png', () {
                          if (item.quantity > 1) {
                            context.read<CartBloc>().add(
                              AddToCartRequested(item.copyWith(quantity: -1))
                            );
                          }
                        }),
                        Container(
                          width: 30,
                          alignment: Alignment.center,
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        _buildIconBtn(context, 'assets/images/more.png', () {
                          context.read<CartBloc>().add(
                            AddToCartRequested(item.copyWith(quantity: 1))
                          );
                        }),
                      ],
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

  Widget _buildIconBtn(BuildContext context, String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: Image.asset(
            assetPath,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.help_outline, size: 14),
          ),
        ),
      ),
    );
  }
}
