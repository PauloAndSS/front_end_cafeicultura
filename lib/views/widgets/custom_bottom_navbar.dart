import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(30), 
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF8FA67E),
          indicatorColor: Colors.white.withOpacity(0.18),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Colors.white, size: 30);
              }
              return const IconThemeData(color: Colors.white70, size: 26);
            },
          ),
        ),
        child: NavigationBar(
          height: 70,
          elevation: 0,
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.coffee_outlined),
              selectedIcon: Icon(Icons.coffee),
              label: 'Atividades',
            ),
            NavigationDestination(
              icon: Icon(Icons.agriculture_outlined),
              selectedIcon: Icon(Icons.agriculture),
              label: 'Talhões',
            ),
            NavigationDestination(
              icon: Icon(Icons.warehouse_outlined),
              selectedIcon: Icon(Icons.warehouse),
              label: 'Armazém',
            ),
            NavigationDestination(
              icon: Icon(Icons.attach_money_outlined),
              selectedIcon: Icon(Icons.attach_money),
              label: 'Financeiro',
            ),
          ],
        ),
      ),
    );
  }
}