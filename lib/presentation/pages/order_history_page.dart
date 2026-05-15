import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chapur_ia/presentation/blocs/order/order_bloc.dart';
import 'package:chapur_ia/presentation/blocs/auth/auth_bloc.dart';
import 'package:chapur_ia/domain/entities/order.dart';
import 'package:intl/intl.dart';
import 'package:chapur_ia/presentation/pages/order_detail_page.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        if (authState.user.isCustomer) {
          context.read<OrderBloc>().add(FetchOrdersRequested(
            accountNumber: authState.user.customerAccountNumber,
          ));
        } else {
          // Salesperson/Admin: Fetch all orders
          context.read<OrderBloc>().add(const FetchOrdersRequested());
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading || state is OrderInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrderFailure) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is OrderListLoaded) {
            if (state.orders.isEmpty) {
              return const Center(child: Text('No se encontraron pedidos.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return _OrderListItem(order: order);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OrderListItem extends StatelessWidget {
  final Order order;
  const _OrderListItem({required this.order});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(symbol: r'$ ', decimalDigits: 2);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailPage(order: order),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PED-${order.legacyOrderId}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      color: Color(0xFF565656),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.customerName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Color(0xFF474747),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              dateFormat.format(order.date),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: Color(0xFF474747),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              currencyFormat.format(order.total),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: Color(0xFFD41E24),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.black, size: 24),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
