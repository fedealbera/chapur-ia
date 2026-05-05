import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/account/account_bloc.dart';
import '../blocs/customer/customer_bloc.dart';
import '../../domain/entities/user.dart';

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
    final user = authState.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: () async {
          _fetchData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(user),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildBalanceCard(),
                    const SizedBox(height: 32),
                    const Text(
                      'ACCESOS RÁPIDOS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B7280),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickAccessGrid(context),
                    const SizedBox(height: 32),
                    _buildContactInfo(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(User user) {
    final initials = user.name.isNotEmpty ? user.name.split(' ').take(2).map((e) => e[0]).join('').toUpperCase() : '??';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF000000), // Dark header as in screenshot
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFE11D48), // Red circle in screenshot
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user.customerName ?? user.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Código: ${user.customerAccountNumber ?? "N/A"}',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        double saldoActual = 0;
        double vencido = 0;

        if (state is AccountSummaryLoaded) {
          saldoActual = state.summary.totalSaldo;
          final now = DateTime.now();
          vencido = state.summary.movements.where((m) => m.pendiente > 0 && m.vto.isBefore(now)).fold(0.0, (sum, m) => sum + m.saldoN);
        }

        return Container(
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saldo Actual',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(saldoActual),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Vencido',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE11D48),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(vencido),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildQuickAccessItem(
          context,
          'Nuevo Pedido',
          Icons.shopping_cart,
          const Color(0xFFE11D48),
          () => widget.onTabSelected(1), // Catálogo
        ),
        _buildQuickAccessItem(
          context,
          'Catálogo',
          Icons.grid_view_rounded,
          const Color(0xFF3B82F6),
          () => widget.onTabSelected(1), // Catálogo
        ),
        _buildQuickAccessItem(
          context,
          'Mis Pedidos',
          Icons.assignment_outlined,
          const Color(0xFFF59E0B),
          () => widget.onTabSelected(2), // Mis Pedidos
        ),
        _buildQuickAccessItem(
          context,
          'Cuenta Corriente',
          Icons.credit_card_outlined,
          const Color(0xFF10B981),
          () => widget.onTabSelected(3), // Cuenta
        ),
      ],
    );
  }

  Widget _buildQuickAccessItem(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
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
        String address = 'Cargando...';
        String phone = 'Cargando...';
        String cuit = 'Cargando...';

        if (state is CustomerSelected) {
          address = '${state.customer.address}, ${state.customer.city}';
          phone = state.customer.phone ?? 'No disponible';
          cuit = state.customer.cuit;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información de Contacto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 20),
              _buildContactRow(Icons.location_on_outlined, address),
              const SizedBox(height: 16),
              _buildContactRow(Icons.phone_outlined, phone),
              const SizedBox(height: 16),
              _buildContactRow(Icons.badge_outlined, 'CUIT: $cuit'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
            ),
          ),
        ),
      ],
    );
  }
}
