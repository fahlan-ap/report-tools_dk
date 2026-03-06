import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_manage_controller.dart';
import '../widgets/empty_state.dart';
import '../widgets/user_dialogs.dart'; // Import file dialog tadi

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserManageController());

    return Scaffold(
      backgroundColor: Colors.transparent,
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF2D2D2D)),
                    ),
                    _buildRefreshButton(controller),
                  ],
                ),
              ),

              // --- LIST USER ---
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.listUser.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                  }
                  if (controller.listUser.isEmpty) {
                    return const EmptyState(message: "Belum ada user dengan role 'user'");
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
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

          // --- FAB TAMBAH (MEMANGGIL DIALOG DARI FILE LAIN) ---
          Positioned(
            bottom: 20,
            right: 20,
            child: SizedBox(
              height: 42, // Konsisten dengan AdminDash
              child: FloatingActionButton.extended(
                onPressed: () => UserDialogs.showAuthDialog(context, controller),
                elevation: 2,
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text("Tambah", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserManageController controller, Map user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.person_rounded, color: Colors.blue, size: 20),
        ),
        title: Text(user['nama_lengkap'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text("NIP: ${user['nip'] ?? '-'}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionIcon(
              icon: Icons.edit_note_rounded,
              color: Colors.orange,
              onTap: () => UserDialogs.showEditProfileDialog(context, controller, user),
            ),
            const SizedBox(width: 4),
            _buildActionIcon(
              icon: Icons.delete_sweep_rounded,
              color: Colors.redAccent,
              onTap: () => UserDialogs.confirmDelete(context, controller, user),
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
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
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
        decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.refresh_rounded, color: Colors.deepPurple, size: 20),
      ),
    );
  }
}