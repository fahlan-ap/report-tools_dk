import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Memberikan sedikit dekorasi agar terlihat lebih premium
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: SalomonBottomBar(
        currentIndex: currentIndex,
        onTap: onTap,
        // Jarak antar item agar pas untuk 5 menu
        itemPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        items: [
          /// Beranda
          SalomonBottomBarItem(
            icon: const Icon(Icons.dashboard_rounded),
            title: const Text("Beranda"),
            selectedColor: Colors.deepPurple,
          ),

          /// Barang
          SalomonBottomBarItem(
            icon: const Icon(Icons.inventory_2),
            title: const Text("Barang"),
            selectedColor: Colors.blue,
          ),

          /// Sekolah
          SalomonBottomBarItem(
            icon: const Icon(Icons.school),
            title: const Text("Sekolah"),
            selectedColor: Colors.orange,
          ),

          /// Teacher
          SalomonBottomBarItem(
            icon: const Icon(Icons.people),
            title: const Text("Teacher"),
            selectedColor: Colors.teal,
          ),

          /// Riwayat
          SalomonBottomBarItem(
            icon: const Icon(Icons.history),
            title: const Text("Riwayat"),
            selectedColor: Colors.pink,
          ),
        ],
      ),
    );
  }
}