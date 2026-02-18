import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_manage_controller.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisiasi Controller
    final controller = Get.put(UserManageController());

    return Column(
      children: [
        // --- HEADER HALAMAN ---
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Manajemen User",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAuthDialog(context, controller),
                    icon: const Icon(Icons.add),
                    label: const Text("Tambah"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // TOMBOL REFRESH
                  IconButton(
                    onPressed: () => controller.fetchUsers(),
                    icon: const Icon(Icons.refresh, color: Colors.deepPurple),
                    tooltip: "Muat ulang data",
                  ),
                ],
              ),
            ],
          ),
        ),

        // --- LIST USER (MENGGUNAKAN OBX) ---
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.listUser.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              );
            }

            if (controller.listUser.isEmpty) {
              return const Center(
                child: Text("Belum ada user dengan role 'user'"),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.listUser.length,
              itemBuilder: (context, index) {
                final user = controller.listUser[index];
                return Card(
                  color: Colors.white,
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: const Icon(Icons.person, color: Colors.blue),
                    ),
                    title: Text(
                      user['nama_lengkap'] ?? '-',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("NIP: ${user['nip'] ?? '-'}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () =>
                              _showEditProfileDialog(context, controller, user),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, controller, user),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // --- LANGKAH 1: DIALOG AUTH (EMAIL & PASSWORD) ---
  void _showAuthDialog(BuildContext context, UserManageController controller) {
    controller.emailController.clear();
    controller.passwordController.clear();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Langkah 1: Akun Login"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Masukkan email dan password untuk akun baru."),
            const SizedBox(height: 15),
            TextField(
              controller: controller.emailController,
              decoration: const InputDecoration(
                  labelText: "Email", prefixIcon: Icon(Icons.email)),
            ),
            TextField(
              controller: controller.passwordController,
              decoration: const InputDecoration(
                  labelText: "Password", prefixIcon: Icon(Icons.lock)),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () async {
                        bool success = await controller.createAuthAccount();
                        if (success) {
                          Get.back();
                          _showAddProfileDialog(context, controller); // Buka Profil
                        }
                      },
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text("Lanjut"),
              )),
        ],
      ),
    );
  }

  // --- LANGKAH 2: DIALOG PROFIL (NAMA & NIP) ---
  void _showAddProfileDialog(BuildContext context, UserManageController controller) {
    controller.namaController.clear();
    controller.nipController.clear();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Langkah 2: Data Profil"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Akun berhasil dibuat. Sekarang lengkapi data profilnya."),
            const SizedBox(height: 15),
            TextField(
              controller: controller.namaController,
              decoration: const InputDecoration(
                  labelText: "Nama Lengkap", prefixIcon: Icon(Icons.person)),
            ),
            TextField(
              controller: controller.nipController,
              decoration: const InputDecoration(
                  labelText: "NIP", prefixIcon: Icon(Icons.badge)),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.saveProfile(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, foregroundColor: Colors.white),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text("Simpan Semua"),
              )),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // --- DIALOG KHUSUS EDIT (HANYA PROFIL) ---
  void _showEditProfileDialog(
      BuildContext context, UserManageController controller, Map user) {
    controller.namaController.text = user['nama_lengkap'] ?? '';
    controller.nipController.text = user['nip'] ?? '';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Edit Profil User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.namaController,
              decoration: const InputDecoration(
                  labelText: "Nama Lengkap", prefixIcon: Icon(Icons.person)),
            ),
            TextField(
              controller: controller.nipController,
              decoration: const InputDecoration(
                  labelText: "NIP", prefixIcon: Icon(Icons.badge)),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.updateUser(user['id']),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text("Perbarui"),
              )),
        ],
      ),
    );
  }

  // Dialog Konfirmasi Hapus
  void _confirmDelete(
      BuildContext context, UserManageController controller, Map user) {
    Get.defaultDialog(
      title: "Hapus User",
      middleText: "Apakah Anda yakin ingin menghapus ${user['nama_lengkap']}?",
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deleteUser(user['id']);
        Get.back();
      },
    );
  }
}