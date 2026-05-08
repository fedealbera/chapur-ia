import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/custom_bottom_nav.dart';
import '../blocs/auth/auth_bloc.dart';
import 'product_catalog_page.dart';
import 'customer_search_page.dart';
import 'order_history_page.dart';
import 'account_summary_page.dart';
import 'customer_home_page.dart';
import 'package:chapur_ia/domain/entities/user.dart';
import '../widgets/cart_icon_badge.dart';
import '../blocs/cart/cart_bloc.dart';
import '../blocs/order/order_bloc.dart';

class DashboardPage extends StatefulWidget {
  final int initialIndex;
  const DashboardPage({super.key, this.initialIndex = 0});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
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
    final List<NavItem> navItems = _getNavItems(user);
    final List<Widget> pages = _getPages(user);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF474747),
        elevation: 0,
        centerTitle: false,
        title: Text(
          navItems[_selectedIndex].title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        actions: const [
          CartIconBadge(),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        items: navItems,
        onItemSelected: (index) {
          if (index == navItems.length - 1 && navItems[index].title == 'Salir') {
            context.read<AuthBloc>().add(LogoutRequested());
            return;
          }
          setState(() => _selectedIndex = index);
          
          final itemTitle = navItems[index].title;
          if (itemTitle == 'Mis pedidos' || itemTitle == 'Pedidos') {
            final authState = context.read<AuthBloc>().state;
            if (authState is Authenticated) {
              context.read<OrderBloc>().add(FetchOrdersRequested(
                    accountNumber: authState.user.isCustomer ? authState.user.customerAccountNumber : null,
                  ));
            }
          }
        },
      ),
    );
  }


  List<NavItem> _getNavItems(User user) {
    if (user.isSalesperson || user.isAdmin) {
      return [
        const NavItem(
          title: 'Clientes',
          assetPath: 'assets/images/users.png',
          fallbackIcon: Icons.people_outline,
        ),
        const NavItem(
          title: 'Catálogos',
          assetPath: 'assets/images/box.png',
          fallbackIcon: Icons.shopping_bag_outlined,
        ),
        const NavItem(
          title: 'Pedidos',
          assetPath: 'assets/images/clipboard_notes.png',
          fallbackIcon: Icons.history_outlined,
        ),
        const NavItem(
          title: 'Salir',
          assetPath: 'assets/images/exit.png',
          fallbackIcon: Icons.logout_outlined,
        ),
      ];
    } else {
      // Customer
      return [
        const NavItem(
          title: 'Inicio',
          assetPath: 'assets/images/home.png', // Assuming home.png exists or use fallback
          fallbackIcon: Icons.home_outlined,
        ),
        const NavItem(
          title: 'Catálogo',
          assetPath: 'assets/images/box.png',
          fallbackIcon: Icons.shopping_bag_outlined,
        ),
        const NavItem(
          title: 'Pedidos',
          assetPath: 'assets/images/clipboard_notes.png',
          fallbackIcon: Icons.history_outlined,
        ),
        const NavItem(
          title: 'Cuenta',
          assetPath: 'assets/images/ctacte.png',
          fallbackIcon: Icons.account_balance_wallet_outlined,
        ),
        const NavItem(
          title: 'Salir',
          assetPath: 'assets/images/exit.png',
          fallbackIcon: Icons.logout_outlined,
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
}
