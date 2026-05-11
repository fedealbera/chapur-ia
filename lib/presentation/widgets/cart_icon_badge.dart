import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/auth/auth_bloc.dart';

import '../pages/cart_page.dart';

class CartIconBadge extends StatelessWidget {
  final Color? color;
  const CartIconBadge({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        int count = 0;
        if (state is CartLoaded) {
          count = state.cart.totalItems;
        }

        return GestureDetector(
          onTap: () {
            final cartBloc = context.read<CartBloc>();
            final cartState = cartBloc.state;
            final authState = context.read<AuthBloc>().state;

            bool isSalesperson = authState is Authenticated && (authState.user.isSalesperson || authState.user.isAdmin);
            bool noCustomer = cartState is CartLoaded && cartState.cart.customerAccountNumber == null;

            if (isSalesperson && noCustomer) {
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
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: cartBloc,
                  child: const CartPage(),
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD61D26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/shopping_cart_white.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
