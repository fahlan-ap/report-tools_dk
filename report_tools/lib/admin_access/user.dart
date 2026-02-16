import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());

    return Column(
      children: [
        // --- HEADER ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Manajemen User",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAuthDialog(context, controller),
                icon: const Icon(Icons.person_add),
                label: const Text("Tambah User"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // --- LIST USER ---
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: controller.userStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final users = snapshot.data ?? [];
              
              if (users.isEmpty) {
                return const Center(child: Text("Belum ada user dengan role 'user'"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                            onPressed: () => _showEditProfileDialog(context, controller, user),
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
            },
          ),
        ),
      ],
    );
  }

  // --- LANGKAH 1: DIALOG AUTH (EMAIL & PASSWORD) ---
  void _showAuthDialog(BuildContext context, UserController controller) {
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
              decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
            ),
            TextField(
              controller: controller.passwordController,
              decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock)),
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
                      Get.back(); // Tutup dialog Auth
                      _showAddProfileDialog(context, controller); // Buka dialog Profil
                    }
                  },
            child: const Text("Lanjut"),
          )),
        ],
      ),
    );
  }

  // --- LANGKAH 2: DIALOG PROFIL (NAMA & NIP) ---
  void _showAddProfileDialog(BuildContext context, UserController controller) {
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
              decoration: const InputDecoration(labelText: "Nama Lengkap", prefixIcon: Icon(Icons.person)),
            ),
            TextField(
              controller: controller.nipController,
              decoration: const InputDecoration(labelText: "NIP", prefixIcon: Icon(Icons.badge)),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : () => controller.saveProfile(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            child: const Text("Simpan Semua"),
          )),
        ],
      ),
      barrierDismissible: false, // User tidak boleh klik di luar agar UUID tidak hilang
    );
  }

  // --- DIALOG KHUSUS EDIT (HANYA PROFIL) ---
  void _showEditProfileDialog(BuildContext context, UserController controller, Map user) {
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
              decoration: const InputDecoration(labelText: "Nama Lengkap", prefixIcon: Icon(Icons.person)),
            ),
            TextField(
              controller: controller.nipController,
              decoration: const InputDecoration(labelText: "NIP", prefixIcon: Icon(Icons.badge)),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Batal")),
          Obx(() => ElevatedButton(
            onPressed: controller.isLoading.value ? null : () => controller.updateUser(user['id']),
            child: const Text("Perbarui"),
          )),
        ],
      ),
    );
  }

  // Dialog Konfirmasi Hapus
  void _confirmDelete(BuildContext context, UserController controller, Map user) {
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