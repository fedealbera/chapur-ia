import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chapur_ia/presentation/blocs/product/product_bloc.dart';
import 'package:chapur_ia/presentation/blocs/cart/cart_bloc.dart';
import 'package:chapur_ia/domain/entities/product.dart';
import 'package:chapur_ia/domain/entities/customer.dart';
import 'package:chapur_ia/domain/entities/cart_item.dart';

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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar productos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  context.read<ProductBloc>().add(FetchProductsRequested(
                        reset: true,
                        priceListCode: widget.customer?.priceListCode,
                      ));
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Catálogo de Productos', style: TextStyle(fontSize: 16)),
              Text(
                widget.customer!.name,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
        body: content,
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
    if (_quantity < widget.product.stockQuantity) {
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
    const primaryRed = Color(0xFFCE1126);
    const lightGrey = Color(0xFFF2F2F2);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.product.articleCode,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          _buildStockBadge(widget.product.stockStatus, widget.product.stockQuantity),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.product.description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        NumberFormat.currency(symbol: 'USD ', decimalDigits: 2).format(widget.product.unitPrice),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          color: primaryRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: lightGrey, thickness: 1.5),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildCircularBtn(Icons.remove, lightGrey, Colors.black, _decrement),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    _buildCircularBtn(Icons.add, lightGrey, Colors.black, _increment),
                  ],
                ),
                ElevatedButton(
                  onPressed: _quantity > 0 ? () {
                    context.read<CartBloc>().add(
                      AddToCartRequested(
                        CartItem(
                          articleCode: widget.product.articleCode,
                          quantity: _quantity,
                          name: widget.product.name,
                          unitPrice: widget.product.unitPrice,
                        ),
                      ),
                    );
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Agregado: $_quantity x ${widget.product.name}'),
                        backgroundColor: primaryRed,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                    
                    setState(() {
                      _quantity = 0; // Reset after adding
                    });
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Agregar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularBtn(IconData icon, Color bgColor, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }

  Widget _buildStockBadge(String status, int quantity) {
    Color color;
    switch (status) {
      case 'VERDE':
        color = Colors.green;
        break;
      case 'AMARILLO':
        color = Colors.orange;
        break;
      case 'ROJO':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            'Stock: $quantity',
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
