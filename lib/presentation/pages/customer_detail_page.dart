import 'package:chapur_ia/presentation/pages/product_catalog_page.dart';
import 'package:chapur_ia/presentation/pages/account_summary_page.dart';
import 'package:flutter/material.dart';
import 'package:chapur_ia/domain/entities/customer.dart';

class CustomerDetailPage extends StatelessWidget {
  final Customer customer;

  const CustomerDetailPage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Cliente'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _buildActions(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F2C),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
            child: const Icon(Icons.business, color: Color(0xFF6366F1), size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            customer.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Cuenta: ${customer.accountNumber}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInfoRow(Icons.location_on_outlined, 'Dirección', '${customer.address}, ${customer.city}'),
            const Divider(height: 32),
            _buildInfoRow(Icons.phone_outlined, 'Teléfono', customer.phone ?? 'No disponible'),
            const Divider(height: 32),
            _buildInfoRow(Icons.badge_outlined, 'CUIT', customer.cuit),
            const Divider(height: 32),
            _buildInfoRow(Icons.description_outlined, 'Condición IVA', customer.condicionIva),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1F2C),
                ),
              ),
            ],
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
          'Nuevo Pedido',
          Icons.add_shopping_cart,
          const Color(0xFF6366F1),
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductCatalogPage(customer: customer),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _buildActionButton(
          context,
          'Cuenta Corriente',
          Icons.account_balance_wallet_outlined,
          const Color(0xFF1A1F2C),
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
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
