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
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0x1A6366F1),
            borderRadius: BorderRadius.all(Radius.circular(12)),
            border: Border.fromBorderSide(BorderSide(color: Color(0x336366F1))),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF6366F1), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ingrese al menos 2 caracteres para buscar clientes por nombre, CUIT o número de cuenta.',
                  style: TextStyle(
                    color: Color(0xFF4338CA),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por CUIT, nombre o cuenta...',
              prefixIcon: const Icon(Icons.person_search_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: const Color(0xFFFAFAFA), // Colors.grey.shade50
            ),
            onChanged: (value) {
              context.read<CustomerBloc>().add(SearchCustomersRequested(term: value, reset: true));
            },
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
                      'Comience a escribir para buscar un cliente',
                      style: TextStyle(color: Color(0xFF757575), fontSize: 16),
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
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0x1A6366F1),
        child: Icon(Icons.business, color: Color(0xFF6366F1)),
      ),
      title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Cuenta: ${customer.accountNumber} | CUIT: ${customer.cuit}'),
      trailing: const Icon(Icons.chevron_right),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFEEEEEE)), // Colors.grey.shade200
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CustomerDetailPage(customer: customer),
          ),
        );
      },
    );
  }
}
