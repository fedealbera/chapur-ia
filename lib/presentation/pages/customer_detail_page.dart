import 'package:chapur_ia/presentation/pages/product_catalog_page.dart';
import 'package:chapur_ia/presentation/pages/account_summary_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chapur_ia/presentation/blocs/cart/cart_bloc.dart';
import 'package:chapur_ia/domain/entities/customer.dart';
import '../widgets/custom_bottom_nav.dart';
import '../blocs/auth/auth_bloc.dart';

class CustomerDetailPage extends StatelessWidget {
  final Customer customer;

  const CustomerDetailPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF474747),
        title: const Text(
          'Perfil del cliente',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            const Text(
              'ACCIONES',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF818080),
              ),
            ),
            const SizedBox(height: 12),
            _buildActions(context),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: 0, // Clientes selected
        onItemSelected: (index) {
          if (index == 0) return; // Already here
          if (index == 3) {
            context.read<AuthBloc>().add(LogoutRequested());
            Navigator.popUntil(context, (route) => route.isFirst);
            return;
          }
          // For other indices, we might want to pop and switch tab in Dashboard
          Navigator.pop(context, index); 
        },
      ),
    );
  }


  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customer.name,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4C4C4C),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Codigo', customer.accountNumber),
          const SizedBox(height: 12),
          _buildInfoRow('Direccion', '${customer.address}, ${customer.city}'),
          const SizedBox(height: 12),
          _buildInfoRow('Telefono', customer.phone ?? 'No disponible'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF474747),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5F5F5F),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          context,
          'Nuevo pedido',
          'Crear un nuevo pedido para este cliente.',
          'assets/images/shopping_cart.png',
          const Color(0xFFD41E24),
          () {
            context.read<CartBloc>().add(SelectCartCustomerRequested(customer.accountNumber));
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductCatalogPage(customer: customer),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          context,
          'Cuenta corriente',
          'Ver saldo y movimientos',
          'assets/images/ctacte.png',
          const Color(0xFF757575),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AccountSummaryPage(customer: customer),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    String subtitle,
    String iconPath,
    Color color,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                iconPath,
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.help_outline),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
