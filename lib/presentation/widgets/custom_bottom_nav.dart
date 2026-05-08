import 'package:flutter/material.dart';

class NavItem {
  final String title;
  final String assetPath;
  final IconData fallbackIcon;

  const NavItem({
    required this.title,
    required this.assetPath,
    required this.fallbackIcon,
  });
}

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final List<NavItem>? items;
  final Function(int) onItemSelected;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.items,
  });

  @override
  Widget build(BuildContext context) {
    // Default items if none provided (for salesperson/backward compatibility)
    final List<NavItem> navItems = items ?? const [
      NavItem(title: 'Clientes', assetPath: 'assets/images/users.png', fallbackIcon: Icons.people_outline),
      NavItem(title: 'Catálogos', assetPath: 'assets/images/box.png', fallbackIcon: Icons.shopping_bag_outlined),
      NavItem(title: 'Pedidos', assetPath: 'assets/images/clipboard_notes.png', fallbackIcon: Icons.history_outlined),
      NavItem(title: 'Salir', assetPath: 'assets/images/exit.png', fallbackIcon: Icons.logout_outlined),
    ];

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          return _buildNavItem(index, item.title, item.assetPath, item.fallbackIcon);
        }),
      ),
    );
  }

  Widget _buildNavItem(int index, String title, String assetPath, IconData fallbackIcon) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onItemSelected(index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0x26C92828) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                assetPath,
                width: 24,
                height: 24,
                color: const Color(0xFF474747),
                errorBuilder: (context, error, stackTrace) => Icon(
                  fallbackIcon,
                  color: const Color(0xFF474747),
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10, // Slightly smaller for 4 items with long text
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: const Color(0xFF474747),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
