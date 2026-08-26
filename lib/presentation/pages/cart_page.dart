import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      ...cart.items.map((item) => _CartProductItem(
                            item: item,
                            usdFormat: _usdFormat,
                          )),
                      const SizedBox(height: 16),
                      // ─── Summary Section ──────────────────────────────────────
                      _buildSummarySection(state),
                    ],
                  ),
                ),
                // ─── Bottom Button ────────────────────────────────────────
                Container(
                  color: const Color(0xFFD61D26),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
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

  Widget _buildSummarySection(CartLoaded state) {
    final cart = state.cart;
    final discounts = state.discounts;

    final double subtotal = cart.subtotalUsd;
    final double iva21 = (discounts?.iva21 ?? 0) > 0 ? discounts!.iva21 : cart.iva21Usd;
    final double iva105 = (discounts?.iva105 ?? 0) > 0 ? discounts!.iva105 : cart.iva105Usd;
    final double total = (discounts?.total ?? 0) > 0 ? discounts!.total : cart.grandTotalUsd;

    final bool showDiscounts = discounts != null &&
        discounts.appliesDiscounts &&
        (discounts.dcgAmount > 0 || discounts.volumeDiscountAmount > 0);

    final bool showFinancials = discounts != null &&
        !discounts.isBiglieri &&
        (discounts.financial30DFFAmount > 0 || discounts.financialCashAmount > 0);

    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen Header
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
          // Resumen Box
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
                _buildSummaryRow('Subtotal', subtotal),
                const SizedBox(height: 12),
                _buildSummaryRow('IVA 21%', iva21),
                if (iva105 != 0) ...[
                  const SizedBox(height: 12),
                  _buildSummaryRow('IVA 10.5%', iva105),
                ],
                const SizedBox(height: 12),
                _buildSummaryRowText(
                  'Costo de Envío',
                  (cart.shippingLabel != null && cart.shippingLabel!.trim().isNotEmpty)
                      ? cart.shippingLabel!
                      : 'GRATIS',
                  textColor: Colors.green,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF2F2F2)),
                ),
                _buildSummaryRow('Total del Pedido', total, isTotal: true),
              ],
            ),
          ),
          
          if (showDiscounts) ...[
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                '🏷  DESCUENTOS',
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
                  if (discounts.dcgAmount > 0)
                    _buildDiscountRow('Dto. Comercial 25%', discounts.dcgAmount),
                  if (!discounts.isBiglieri && discounts.volumeDiscountAmount > 0) ...[
                    if (discounts.dcgAmount > 0) const SizedBox(height: 12),
                    _buildDiscountRow('Dto. por Volumen', discounts.volumeDiscountAmount),
                    if (discounts.grpMaq > 0) _buildSubDiscountRow('MAQ (10%)', discounts.grpMaq),
                    if (discounts.grpAcc > 0) _buildSubDiscountRow('ACC (5%)', discounts.grpAcc),
                    if (discounts.grpRep > 0) _buildSubDiscountRow('REP (8%)', discounts.grpRep),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Color(0xFFF2F2F2)),
                  ),
                  _buildSummaryRow('Total c/Dto. Comercial', discounts.montoTotal2, isBoldText: true),
                ],
              ),
            ),
          ],

          if (showFinancials) ...[
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                '💳  DESCUENTOS OPCIONALES',
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
                  if (discounts.financial30DFFAmount > 0) ...[
                    _buildDiscountRow('Dto. 30 D F/F 15%', discounts.financial30DFFAmount),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Total c/Dto. 30 D F/F', discounts.montoTotal3, isBoldText: true),
                  ],
                  if (discounts.financial30DFFAmount > 0 && discounts.financialCashAmount > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: Color(0xFFF2F2F2)),
                    ),
                  if (discounts.financialCashAmount > 0) ...[
                    _buildDiscountRow('Dto. Contado 5%', discounts.financialCashAmount),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Total c/Dto. Contado', discounts.montoTotal4, isBoldText: true),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRowText(String label, String text, {Color? textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF474747),
            fontFamily: 'Inter',
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor ?? const Color(0xFF474747),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildDiscountRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF474747),
            fontFamily: 'Inter',
          ),
        ),
        Text(
          '-${_usdFormat.format(amount)}',
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF474747),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }

  Widget _buildSubDiscountRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF818080),
              fontFamily: 'Inter',
            ),
          ),
          Text(
            '-${_usdFormat.format(amount)}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF818080),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false, bool isBoldText = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isTotal || isBoldText ? FontWeight.bold : FontWeight.normal,
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

class _CartProductItem extends StatefulWidget {
  final CartItem item;
  final NumberFormat usdFormat;

  const _CartProductItem({
    required this.item,
    required this.usdFormat,
  });

  @override
  State<_CartProductItem> createState() => _CartProductItemState();
}

class _CartProductItemState extends State<_CartProductItem> {
  late TextEditingController _quantityController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '${widget.item.quantity}');
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _quantityController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _quantityController.text.length,
        );
      } else {
        _submitNewQuantity();
      }
    });
  }

  @override
  void didUpdateWidget(_CartProductItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.quantity != oldWidget.item.quantity && !_focusNode.hasFocus) {
      _quantityController.text = '${widget.item.quantity}';
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitNewQuantity() {
    if (_quantityController.text.isEmpty) {
      _quantityController.text = '${widget.item.quantity}';
      return;
    }
    final val = int.tryParse(_quantityController.text) ?? widget.item.quantity;
    if (val == widget.item.quantity) {
      return;
    }
    if (val < 1) {
      _quantityController.text = '${widget.item.quantity}';
      return;
    }

    final difference = val - widget.item.quantity;
    context.read<CartBloc>().add(
      AddToCartRequested(widget.item.copyWith(quantity: difference))
    );
  }

  @override
  Widget build(BuildContext context) {
    final unitPrice = widget.item.priceUsd ?? 0.0;
    
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
              imageUrl: widget.item.imageUrl ?? '',
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
                        widget.item.description ?? 'Producto',
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
                        context.read<CartBloc>().add(RemoveFromCartRequested(widget.item.articleCode));
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
                  '${widget.item.quantity} x ${widget.usdFormat.format(unitPrice)}',
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
                      widget.usdFormat.format(unitPrice),
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
                          if (widget.item.quantity > 1) {
                            context.read<CartBloc>().add(
                              AddToCartRequested(widget.item.copyWith(quantity: -1))
                            );
                          }
                        }),
                        Container(
                          width: 65,
                          height: 32,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _focusNode.hasFocus 
                                  ? const Color(0xFFD61D26) 
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: _quantityController,
                            focusNode: _focusNode,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _focusNode.unfocus(),
                          ),
                        ),
                        _buildIconBtn(context, 'assets/images/more.png', () {
                          context.read<CartBloc>().add(
                            AddToCartRequested(widget.item.copyWith(quantity: 1))
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
