import 'package:chapur_ia/presentation/pages/customer_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chapur_ia/presentation/blocs/customer/customer_bloc.dart';
import 'package:chapur_ia/domain/entities/customer.dart';

class CustomerSearchPage extends StatefulWidget {
  const CustomerSearchPage({super.key});

  @override
  State<CustomerSearchPage> createState() => _CustomerSearchPageState();
}

class _CustomerSearchPageState extends State<CustomerSearchPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // No cargamos clientes inicialmente para evitar errores de búsqueda vacía
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: const Color(0xFF474747),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar producto', // Matching the text in the provided image
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
                onChanged: (value) {
                  context.read<CustomerBloc>().add(SearchCustomersRequested(term: value, reset: true));
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              if (state is CustomerLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CustomerFailure) {
                return Center(child: Text('Error: ${state.message}'));
              } else if (state is CustomerListLoaded) {
                if (state.customers.isEmpty) {
                  return const Center(child: Text('No se encontraron clientes.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.customers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final customer = state.customers[index];
                    return _CustomerListItem(customer: customer);
                  },
                );
              }
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 64, color: Color(0xFFE0E0E0)),
                    SizedBox(height: 16),
                    Text(
                      'Comience a escribir para buscar un cliente, debe ingresar al menos 2 caracteres para la búsqueda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Color(0xFF757575),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CustomerListItem extends StatelessWidget {
  final Customer customer;
  const _CustomerListItem({required this.customer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          customer.name,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF474747),
          ),
        ),
        subtitle: Text(
          customer.accountNumber, // Assuming account number is the CLI-001 part
          style: TextStyle(
            fontFamily: 'Inter',
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        trailing: Image.asset(
          'assets/images/arrow_right.png',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.arrow_forward, color: Colors.black),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CustomerDetailPage(customer: customer),
            ),
          );
        },
      ),
    );
  }
}
