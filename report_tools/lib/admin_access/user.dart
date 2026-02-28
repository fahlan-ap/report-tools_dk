import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_manage_controller.dart';
import '../widgets/empty_state.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisiasi Controller
    final controller = Get.put(UserManageController());

    return Scaffold(
      backgroundColor: Colors.transparent, // Mengikuti background AdminDash
      body: Stack(
        children: [
          Column(
            children: [
              // --- HEADER HALAMAN ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Manajemen User",
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2D2D2D)
                      ),
                    ),
                    _buildRefreshButton(controller),
                  ],
                ),
              ),

              // --- LIST USER (MENGGUNAKAN OBX) ---
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.listUser.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                  }

                  if (controller.listUser.isEmpty) {
                    return const EmptyState(message: "Belum ada user dengan role 'user'");
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100), // Padding bawah untuk FAB
                    itemCount: controller.listUser.length,
                    itemBuilder: (context, index) {
                      final user = controller.listUser[index];
                      return _buildUserCard(context, controller, user);
                    },
                  );
                }),
              ),
            ],
          ),

          // --- FLOATING ACTION BUTTON (COMPACT VERSION) ---
          Positioned(
            bottom: 20,
            right: 20,
            child: SizedBox(
              height: 50,
              child: FloatingActionButton.extended(
                onPressed: () => _showAuthDialog(context, controller),
                elevation: 2,
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
                icon: const Icon(Icons.person_add_rounded),
                label: const Text(
                  "Tambah", 
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: CARD USER (COMPACT) ---
  Widget _buildUserCard(BuildContext context, UserManageController controller, Map user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.person_rounded, color: Colors.blue, size: 20),
        ),
        title: Text(
          user['nama_lengkap'] ?? '-',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          "NIP: ${user['nip'] ?? '-'}",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionIcon(
              icon: Icons.edit_note_rounded,
              color: Colors.orange,
              onTap: () => _showEditProfileDialog(context, controller, user),
            ),
            const SizedBox(width: 4),
            _buildActionIcon(
              icon: Icons.delete_sweep_rounded,
              color: Colors.redAccent,
              onTap: () => _confirmDelete(context, controller, user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildRefreshButton(UserManageController controller) {
    return InkWell(
      onTap: () => controller.fetchUsers(),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.refresh_rounded, color: Colors.deepPurple, size: 20),
      ),
    );
  }

  // --- DIALOGS (AUTH, ADD PROFILE, EDIT, DELETE) ---
  void _showAuthDialog(BuildContext context, UserManageController controller) {
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
                _showAddProfileDialog(context, controller);
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

  void _showAddProfileDialog(BuildContext context, UserManageController controller) {
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

  void _showEditProfileDialog(BuildContext context, UserManageController controller, Map user) {
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

  void _confirmDelete(BuildContext context, UserManageController controller, Map user) {
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