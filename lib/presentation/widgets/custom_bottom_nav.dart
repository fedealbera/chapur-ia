import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
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
        children: [
          _buildNavItem(0, 'Clientes', 'assets/images/users.png', Icons.people_outline),
          _buildNavItem(1, 'Catálogos', 'assets/images/box.png', Icons.shopping_bag_outlined),
          _buildNavItem(2, 'Pedidos', 'assets/images/clipboard_notes.png', Icons.history_outlined),
          _buildNavItem(3, 'Salir', 'assets/images/exit.png', Icons.logout_outlined),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String title, String assetPath, IconData fallbackIcon) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onItemSelected(index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
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
