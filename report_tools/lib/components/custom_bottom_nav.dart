import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key, 
    required this.currentIndex, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Barang'),
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Sekolah'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Teacher'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
      ],
    );
  }
}