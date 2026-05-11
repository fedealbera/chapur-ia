import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/account/account_bloc.dart';
import '../blocs/customer/customer_bloc.dart';


class CustomerHomePage extends StatefulWidget {
  final Function(int) onTabSelected;
  const CustomerHomePage({super.key, required this.onTabSelected});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage> {
  final currencyFormat = NumberFormat.currency(locale: 'es_AR', symbol: '\$ ');

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated && authState.user.isCustomer) {
      final accountNumber = authState.user.customerAccountNumber;
      if (accountNumber != null) {
        // Fetch account summary
        context.read<AccountBloc>().add(FetchAccountSummaryRequested(
              accountNumber: accountNumber,
              startDate: DateTime.now().subtract(const Duration(days: 365)),
              endDate: DateTime.now(),
            ));

        // Fetch customer detail for contact info
        context.read<CustomerBloc>().add(SelectCustomerRequested(accountNumber));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! Authenticated) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildBalanceCard(),
                const SizedBox(height: 32),
                const Text(
                  'ACCESOS RAPIDOS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF818080),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),
                _buildQuickAccessGrid(context),
                const SizedBox(height: 32),
                const Text(
                  'INFORMACION DE CONTACTO',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF818080),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 16),
                _buildContactInfo(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }



  Widget _buildBalanceCard() {
    // Hardcoded values as requested for now
    const double saldoTotalValue = 2547850;
    const double vencidoValue = 485000;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Saldo total',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF474747),
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(saldoTotalValue),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF474747),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFD41E24).withValues(alpha: 0.15), // #D41E2426
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/alert_red.png',
                      width: 16,
                      height: 16,
                      errorBuilder: (context, error, stackTrace) => 
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFD41E24), size: 16),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Vencido',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFD41E24),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormat.format(vencidoValue),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD41E24),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildQuickAccessItem(
          context,
          'Nuevo pedido',
          'assets/images/shopping_cart_white.png',
          Icons.shopping_cart,
          const Color(0xFFD40924),
          () => widget.onTabSelected(1), // Catálogo
        ),
        _buildQuickAccessItem(
          context,
          'Catalogo',
          'assets/images/box_white.png',
          Icons.grid_view_rounded,
          const Color(0xFF2265FF),
          () => widget.onTabSelected(1), // Catálogo
        ),
        _buildQuickAccessItem(
          context,
          'Mis pedidos',
          'assets/images/clipboard_notes_white.png',
          Icons.assignment_outlined,
          const Color(0xFFFB8700),
          () => widget.onTabSelected(2), // Mis Pedidos
        ),
        _buildQuickAccessItem(
          context,
          'Cuenta corriente',
          'assets/images/ctacte_white.png',
          Icons.credit_card_outlined,
          const Color(0xFF01B36A),
          () => widget.onTabSelected(3), // Cuenta
        ),
      ],
    );
  }

  Widget _buildQuickAccessItem(
    BuildContext context,
    String label,
    String assetPath,
    IconData fallbackIcon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  assetPath,
                  width: 24,
                  height: 24,
                  color: Colors.white,
                  errorBuilder: (context, error, stackTrace) => 
                    Icon(fallbackIcon, color: Colors.white, size: 24),
                ),
              ],
            ),
            Text(
              label.contains(' ') ? label.replaceFirst(' ', '\n') : label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Inter',
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        String address = '...';
        String phone = '...';
        String email = '...';

        if (state is CustomerSelected) {
          address = '${state.customer.address}, ${state.customer.city}';
          phone = state.customer.phone ?? 'No disponible';
          email = state.customer.email ?? 'No disponible';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEEEEE)),
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
              _buildContactRow('Direccion', address),
              const SizedBox(height: 16),
              _buildContactRow('Telefono', phone),
              const SizedBox(height: 16),
              _buildContactRow('Email', email),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF474747),
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF696969),
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }
}
