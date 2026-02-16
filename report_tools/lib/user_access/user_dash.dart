import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class UserDash extends StatelessWidget {
  const UserDash({super.key});

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Peminjaman Alat"),
        actions: [
          IconButton(
            onPressed: () => authC.logout(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_shopping_cart, size: 100, color: Colors.blueGrey),
            const SizedBox(height: 20),
            const Text(
              "Halo Karyawan!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Text(
                "Di sini kamu bisa memilih alat yang ingin dipinjam dan sekolah tujuan.",
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed('/user-status'),
              icon: const Icon(Icons.info_outline),
              label: const Text("Cek Status Pinjaman Saya"),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.snackbar("Info", "Form peminjaman segera hadir"),
        label: const Text("Pinjam Alat"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}