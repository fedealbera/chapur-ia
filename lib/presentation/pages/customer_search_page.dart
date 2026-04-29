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
    // Carga inicial de todos los clientes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerBloc>().add(const SearchCustomersRequested(term: '', reset: true));
    });
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por CUIT, nombre o cuenta...',
              prefixIcon: const Icon(Icons.person_search_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (value) {
              if (value.isEmpty || value.length >= 2) {
                context.read<CustomerBloc>().add(SearchCustomersRequested(term: value, reset: true));
              }
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
              return const Center(child: Text('Comienza a buscar un cliente.'));
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
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF6366F1).withValues(alpha: 0.1),
        child: const Icon(Icons.business, color: Color(0xFF6366F1)),
      ),
      title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Cuenta: ${customer.accountNumber} | CUIT: ${customer.cuit}'),
      trailing: const Icon(Icons.chevron_right),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
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
