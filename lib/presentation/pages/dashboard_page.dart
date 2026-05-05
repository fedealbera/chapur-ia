import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import 'product_catalog_page.dart';
import 'customer_search_page.dart';
import 'order_history_page.dart';
import 'account_summary_page.dart';
import 'customer_home_page.dart';
import 'package:chapur_ia/domain/entities/user.dart';
import '../widgets/cart_icon_badge.dart';
import '../blocs/cart/cart_bloc.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load cart on dashboard start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartBloc>().add(LoadCartRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AuthBloc>().state;
    if (userState is! Authenticated) return const SizedBox.shrink();

    final user = userState.user;
    
    // Define navigation items and pages based on role
    final List<_NavItem> navItems = _getNavItems(user);
    final List<Widget> pages = _getPages(user);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          navItems[_selectedIndex].title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          const CartIconBadge(),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
          ),
        ],
      ),
      drawer: _buildDrawer(user, navItems),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: navItems.map((item) => item.bottomNavItem).toList(),
      ),
    );
  }

  List<_NavItem> _getNavItems(User user) {
    if (user.isSalesperson || user.isAdmin) {
      return [
        const _NavItem(
          title: 'Clientes',
          icon: Icons.people_outline,
          bottomNavItem: BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: 'Clientes',
          ),
        ),
        const _NavItem(
          title: 'Catálogos',
          icon: Icons.shopping_bag_outlined,
          bottomNavItem: BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Catálogos',
          ),
        ),
        const _NavItem(
          title: 'Pedidos',
          icon: Icons.history_outlined,
          bottomNavItem: BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: 'Pedidos',
          ),
        ),
      ];
    } else {
      // Customer
      return [
        const _NavItem(
          title: 'Inicio',
          icon: Icons.home_outlined,
          bottomNavItem: BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
        ),
        const _NavItem(
          title: 'Catálogo',
          icon: Icons.shopping_bag_outlined,
          bottomNavItem: BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Catálogo',
          ),
        ),
        const _NavItem(
          title: 'Mis Pedidos',
          icon: Icons.history_outlined,
          bottomNavItem: BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: 'Mis Pedidos',
          ),
        ),
        const _NavItem(
          title: 'Cuenta',
          icon: Icons.account_balance_wallet_outlined,
          bottomNavItem: BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Cuenta',
          ),
        ),
      ];
    }
  }

  List<Widget> _getPages(User user) {
    if (user.isSalesperson || user.isAdmin) {
      return [
        const CustomerSearchPage(),
        const ProductCatalogPage(),
        const OrderHistoryPage(),
      ];
    } else {
      return [
        CustomerHomePage(
          onTabSelected: (index) => setState(() => _selectedIndex = index),
        ),
        const ProductCatalogPage(),
        const OrderHistoryPage(),
        const AccountSummaryPage(),
      ];
    }
  }

  Widget _buildDrawer(User user, List<_NavItem> navItems) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1A1F2C)),
            accountName: Text(user.name),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: const Color(0xFF6366F1),
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return ListTile(
                    leading: Icon(item.icon),
                    title: Text(item.title),
                    selected: _selectedIndex == index,
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      Navigator.pop(context);
                    },
                  );
                }),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout_outlined, color: Colors.redAccent),
                  title: const Text('Salir', style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(context);
                    context.read<AuthBloc>().add(LogoutRequested());
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Versión 1.0.0',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String title;
  final IconData icon;
  final BottomNavigationBarItem bottomNavItem;

  const _NavItem({
    required this.title,
    required this.icon,
    required this.bottomNavItem,
  });
}
