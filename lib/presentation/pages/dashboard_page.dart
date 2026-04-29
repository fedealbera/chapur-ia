import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import 'product_catalog_page.dart';
import 'customer_search_page.dart';
import 'order_history_page.dart';
import 'account_summary_page.dart';
import 'package:chapur_ia/domain/entities/user.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AuthBloc>().state;
    if (userState is! Authenticated) return const SizedBox.shrink();

    final user = userState.user;
    final bool canSearchCustomers = user.isAdmin || user.isSalesperson;

    final List<Widget> pages = [
      if (canSearchCustomers) const CustomerSearchPage(),
      const ProductCatalogPage(),
      const OrderHistoryPage(),
      const AccountSummaryPage(),
    ];

    final List<BottomNavigationBarItem> navItems = [
      if (canSearchCustomers)
        const BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          label: 'Clientes',
        ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag_outlined),
        label: 'Catálogos',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.history_outlined),
        label: 'Pedidos',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.account_balance_wallet_outlined),
        label: 'Cta Cte',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitle(_selectedIndex, canSearchCustomers),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
          ),
        ],
      ),
      drawer: _buildDrawer(user),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
    );
  }

  String _getTitle(int index, bool canSearch) {
    if (canSearch) {
      switch (index) {
        case 0: return 'Gestión de Clientes';
        case 1: return 'Catálogo de Productos';
        case 2: return 'Seguimiento de Pedidos';
        case 3: return 'Estado de Cuenta';
        default: return '';
      }
    } else {
      switch (index) {
        case 0: return 'Catálogo de Productos';
        case 1: return 'Seguimiento de Pedidos';
        case 2: return 'Estado de Cuenta';
        default: return '';
      }
    }
  }

  Widget _buildDrawer(User user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1A1F2C)),
            accountName: Text(user.name),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: const Color(0xFF6366F1),
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            otherAccountsPictures: [
               Chip(
                label: Text(
                  user.role.toUpperCase(),
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
                backgroundColor: Colors.white24,
              ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Mi Perfil'),
            onTap: () {},
          ),
          if (user.customerName != null)
            ListTile(
              leading: const Icon(Icons.business_outlined),
              title: const Text('Cliente Actual'),
              subtitle: Text(user.customerName!),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configuración'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Soporte Ayuda'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
