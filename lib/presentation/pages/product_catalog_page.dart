import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chapur_ia/presentation/blocs/product/product_bloc.dart';
import 'package:chapur_ia/presentation/blocs/cart/cart_bloc.dart';
import 'package:chapur_ia/presentation/blocs/auth/auth_bloc.dart';
import 'package:chapur_ia/domain/entities/product.dart';
import 'package:chapur_ia/domain/entities/customer.dart';
import 'package:chapur_ia/domain/entities/cart_item.dart';
import '../widgets/cart_icon_badge.dart';
import '../widgets/custom_bottom_nav.dart';
import 'dashboard_page.dart';

class ProductCatalogPage extends StatefulWidget {
  final Customer? customer;
  const ProductCatalogPage({super.key, this.customer});

  @override
  State<ProductCatalogPage> createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Initial fetch with customer context if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().add(FetchProductsRequested(
            reset: true,
            priceListCode: widget.customer?.priceListCode,
          ));
      context.read<CartBloc>().add(LoadCartRequested());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<ProductBloc>().state;
      if (state is ProductListLoaded && !state.hasReachedMax) {
        context.read<ProductBloc>().add(FetchProductsRequested(
              search: _searchController.text,
              priceListCode: state.priceListCode,
            ));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated && (authState.user.isSalesperson || authState.user.isAdmin)) {
              return BlocBuilder<CartBloc, CartState>(
                builder: (context, cartState) {
                  final bool noCustomer = cartState is CartLoaded && cartState.cart.customerAccountNumber == null;
                  if (noCustomer) {
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4E5), // Light orange matching capture
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFFD580)), // Orange border
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Color(0xFFED6C02), size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Debe seleccionar un cliente antes de realizar un pedido.',
                              style: TextStyle(
                                color: Color(0xFF663C00), 
                                fontWeight: FontWeight.bold, 
                                fontSize: 14,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Container(
          width: double.infinity,
          color: const Color(0xFF474747),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Buscar producto',
              hintStyle: TextStyle(color: Colors.grey.shade600, fontFamily: 'Inter'),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  'assets/images/search.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.search, color: Colors.grey),
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (value) {
              final state = context.read<ProductBloc>().state;
              String? currentPriceList;
              if (state is ProductListLoaded) {
                currentPriceList = state.priceListCode;
              }
              context.read<ProductBloc>().add(FetchProductsRequested(
                    reset: true,
                    search: value,
                    priceListCode: currentPriceList ?? widget.customer?.priceListCode,
                  ));
            },
          ),
        ),
        Expanded(
          child: MultiBlocListener(
            listeners: [
              BlocListener<CartBloc, CartState>(
                listener: (context, state) {
                  if (state is CartFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                    );
                  } else if (state is CartLoaded) {
                    // Feedback handled locally in the item for now, 
                    // but we could add a floating button or something here.
                  }
                },
              ),
            ],
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProductFailure) {
                  return _buildErrorState(state.message);
                } else if (state is ProductListLoaded) {
                  if (state.products.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.hasReachedMax ? state.products.length : state.products.length + 1,
                    itemBuilder: (context, index) {
                      if (index >= state.products.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final product = state.products[index];
                      return _ProductListItem(product: product);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );

    if (widget.customer != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF474747),
          iconTheme: const IconThemeData(color: Colors.white),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Catálogo de Productos',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                widget.customer!.name,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          actions: const [
            CartIconBadge(),
          ],
        ),
        body: content,
        bottomNavigationBar: CustomBottomNav(
          selectedIndex: 1, // Catálogos selected
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

    return content;
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFCE1126),
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No se pudo cargar el catálogo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<ProductBloc>().add(FetchProductsRequested(
                        reset: true,
                        search: _searchController.text,
                        priceListCode: widget.customer?.priceListCode,
                      ));
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('REINTENTAR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCE1126),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'No se encontraron productos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductListItem extends StatefulWidget {
  final Product product;
  const _ProductListItem({required this.product});

  @override
  State<_ProductListItem> createState() => _ProductListItemState();
}

class _ProductListItemState extends State<_ProductListItem> {
  int _quantity = 0;

  void _increment() {
    final authState = context.read<AuthBloc>().state;
    final bool isCustomer = authState is Authenticated && authState.user.isCustomer;

    if (isCustomer || _quantity < widget.product.stockQuantity) {
      setState(() {
        _quantity++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay más stock disponible'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _decrement() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

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
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: widget.product.imageUrl.isNotEmpty
                    ? Image.network(widget.product.imageUrl, fit: BoxFit.contain)
                    : const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.articleCode,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF474747),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.product.description.isNotEmpty)
                      Text(
                        widget.product.description,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Color(0xFF565656),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (widget.product.name.isNotEmpty && widget.product.name != widget.product.description)
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Color(0xFF565656),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 2),
                    Text(
                      NumberFormat.currency(symbol: 'USD ', decimalDigits: 2).format(widget.product.unitPrice),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900,
                        fontSize: 19,
                        color: Color(0xFFDE535C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStockText(context, widget.product.stockStatus, widget.product.stockQuantity),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: Color(0xFFF2F2F2)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildIconBtn('assets/images/less.png', _decrement),
                  Container(
                    width: 40,
                    alignment: Alignment.center,
                    child: Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  _buildIconBtn('assets/images/more.png', _increment),
                ],
              ),
              ElevatedButton(
                onPressed: _quantity > 0 ? () {
                  final cartState = context.read<CartBloc>().state;
                  final authState = context.read<AuthBloc>().state;
                  
                  bool isSalesperson = authState is Authenticated && (authState.user.isSalesperson || authState.user.isAdmin);
                  bool noCustomer = cartState is CartLoaded && cartState.cart.customerAccountNumber == null;

                  if (isSalesperson && noCustomer) {
                    _showNoCustomerAlert(context);
                    return;
                  }

                  context.read<CartBloc>().add(
                    AddToCartRequested(
                      CartItem(
                        articleCode: widget.product.articleCode,
                        quantity: _quantity,
                        description: widget.product.name,
                        unitPrice: widget.product.unitPrice,
                      ),
                    ),
                  );
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Agregado: ${widget.product.name}'),
                      backgroundColor: const Color(0xFFD61D26),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                  
                  setState(() {
                    _quantity = 0; 
                  });
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD61D26),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 4),
                    Text(
                      'Agregar',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconBtn(String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
            assetPath,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.help_outline, size: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildStockText(BuildContext context, String status, int quantity) {
    final authState = context.read<AuthBloc>().state;
    final bool isCustomer = authState is Authenticated && authState.user.isCustomer;

    Color color;
    String stockLabel;

    switch (status) {
      case 'VERDE':
        color = Colors.green;
        stockLabel = isCustomer ? 'Disponible' : '$quantity unidades';
        break;
      case 'AMARILLO':
        color = Colors.orange;
        stockLabel = isCustomer ? 'Stock limitado' : '$quantity unidades';
        break;
      case 'ROJO':
        color = Colors.red;
        stockLabel = isCustomer ? 'No disponible' : '$quantity unidades';
        break;
      default:
        color = Colors.grey;
        stockLabel = '$quantity unidades';
    }

    return Text(
      'Stock: $stockLabel',
      style: TextStyle(
        fontFamily: 'Inter',
        color: color,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  void _showNoCustomerAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFED6C02)),
            SizedBox(width: 8),
            Text('Atención'),
          ],
        ),
        content: const Text(
          'Para poder armar el carrito de compras es requerimiento seleccionar a un cliente previamente.',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ENTENDIDO', style: TextStyle(color: Color(0xFFD61D26), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
