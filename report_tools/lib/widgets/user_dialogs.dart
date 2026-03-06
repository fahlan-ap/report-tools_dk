import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/user_manage_controller.dart';

class UserDialogs {
  static void showAuthDialog(BuildContext context, UserManageController controller) {
    controller.emailController.clear();
    controller.passwordController.clear();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Langkah 1: Akun Login", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.emailController,
              decoration: InputDecoration(
                labelText: "Email", 
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.passwordController,
              decoration: InputDecoration(
                labelText: "Password", 
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
            onPressed: controller.isLoading.value ? null : () async {
              bool success = await controller.createAuthAccount();
              if (success) {
                Get.back();
                showAddProfileDialog(context, controller); // Panggil langkah 2
              }
            },
            child: controller.isLoading.value 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text("Lanjut"),
          )),
        ],
      ),
    );
  }

  static void showAddProfileDialog(BuildContext context, UserManageController controller) {
    controller.namaController.clear();
    controller.nipController.clear();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Langkah 2: Profil", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.namaController,
              decoration: InputDecoration(
                labelText: "Nama Lengkap", 
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.nipController,
              decoration: InputDecoration(
                labelText: "NIP", 
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            onPressed: controller.isLoading.value ? null : () => controller.saveProfile(),
            child: const Text("Simpan Semua"),
          )),
        ],
      ),
      barrierDismissible: false,
    );
  }

  static void showEditProfileDialog(BuildContext context, UserManageController controller, Map user) {
    controller.namaController.text = user['nama_lengkap'] ?? '';
    controller.nipController.text = user['nip'] ?? '';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Profil", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.namaController,
              decoration: InputDecoration(
                labelText: "Nama Lengkap", 
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.nipController,
              decoration: InputDecoration(
                labelText: "NIP", 
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            onPressed: controller.isLoading.value ? null : () => controller.updateUser(user['id']),
            child: const Text("Perbarui"),
          )),
        ],
      ),
    );
  }

  static void confirmDelete(BuildContext context, UserManageController controller, Map user) {
    Get.defaultDialog(
      title: "Hapus User",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: "Hapus ${user['nama_lengkap']}?",
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        controller.deleteUser(user['id']);
        Get.back();
      },
    );
  }
}