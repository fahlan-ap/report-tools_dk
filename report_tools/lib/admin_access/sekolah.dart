import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sekolah_controller.dart';
import '../widgets/empty_state.dart';

class SekolahPage extends StatelessWidget {
  const SekolahPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisiasi Controller
    final controller = Get.put(SekolahController());

    return Scaffold(
      backgroundColor: Colors.transparent, // Mengikuti background AdminDash
      body: Stack(
        children: [
          Column(
            children: [
              // --- HEADER HALAMAN ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Daftar Sekolah",
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

              // --- LIST DATA SEKOLAH (MENGGUNAKAN OBX) ---
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.listSekolah.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                  }

                  if (controller.listSekolah.isEmpty) {
                    return const EmptyState(message: "Belum ada data sekolah");
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100), // Padding bawah untuk FAB
                    itemCount: controller.listSekolah.length,
                    itemBuilder: (context, index) {
                      final sekolah = controller.listSekolah[index];
                      return _buildSekolahCard(context, controller, sekolah);
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
                onPressed: () => _showFormDialog(context, controller),
                elevation: 2,
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
                icon: const Icon(Icons.add_rounded),
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

  // --- WIDGET HELPER: CARD SEKOLAH (COMPACT) ---
  Widget _buildSekolahCard(BuildContext context, SekolahController controller, Map sekolah) {
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
            color: Colors.green.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.school_rounded, color: Colors.green, size: 20),
        ),
        title: Text(
          sekolah['nama_sekolah'] ?? "-",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          "ID: ${sekolah['id'].toString().toUpperCase().substring(0, 8)}",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionIcon(
              icon: Icons.edit_note_rounded,
              color: Colors.orange,
              onTap: () => _showFormDialog(context, controller, sekolah: sekolah),
            ),
            const SizedBox(width: 4),
            _buildActionIcon(
              icon: Icons.delete_sweep_rounded,
              color: Colors.redAccent,
              onTap: () => _confirmDelete(context, controller, sekolah),
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

  Widget _buildRefreshButton(SekolahController controller) {
    return InkWell(
      onTap: () => controller.fetchSekolah(),
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

  // --- DIALOG FORM (TAMBAH & EDIT) ---
  void _showFormDialog(BuildContext context, SekolahController controller, {Map? sekolah}) {
    bool isEdit = sekolah != null;
    if (isEdit) {
      controller.namaSekolahController.text = sekolah['nama_sekolah'];
    } else {
      controller.namaSekolahController.clear();
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEdit ? "Edit Nama Sekolah" : "Tambah Sekolah Baru",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: TextField(
          controller: controller.namaSekolahController,
          decoration: InputDecoration(
            labelText: "Nama Sekolah",
            prefixIcon: const Icon(Icons.school_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isEdit ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: controller.isLoading.value 
                ? null 
                : () => isEdit ? controller.updateSekolah(sekolah['id']) : controller.addSekolah(),
            child: controller.isLoading.value 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(isEdit ? "Perbarui" : "Simpan"),
          )),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // --- DIALOG KONFIRMASI HAPUS ---
  void _confirmDelete(BuildContext context, SekolahController controller, Map sekolah) {
    Get.defaultDialog(
      title: "Hapus Sekolah",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: "Yakin ingin menghapus '${sekolah['nama_sekolah']}'?",
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        controller.deleteSekolah(sekolah['id']);
        Get.back();
      },
    );
  }
}