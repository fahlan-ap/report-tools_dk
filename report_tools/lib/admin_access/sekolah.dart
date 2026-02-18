import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sekolah_controller.dart';

class SekolahPage extends StatelessWidget {
  const SekolahPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisiasi Controller
    final controller = Get.put(SekolahController());

    return Column(
      children: [
        // --- HEADER HALAMAN ---
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Daftar Sekolah",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showFormDialog(context, controller),
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
                    onPressed: () => controller.fetchSekolah(),
                    icon: const Icon(Icons.refresh, color: Colors.deepPurple),
                    tooltip: "Muat ulang data",
                  ),
                ],
              ),
            ],
          ),
        ),

        // --- LIST DATA SEKOLAH (MENGGUNAKAN OBX) ---
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.listSekolah.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              );
            }

            if (controller.listSekolah.isEmpty) {
              return const Center(
                child: Text("Belum ada data sekolah."),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.listSekolah.length,
              itemBuilder: (context, index) {
                final sekolah = controller.listSekolah[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade50,
                      child: const Icon(Icons.school, color: Colors.green),
                    ),
                    title: Text(
                      sekolah['nama_sekolah'] ?? "-",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "ID: ${sekolah['id'].toString().substring(0, 8)}...",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                          onPressed: () => _showFormDialog(context, controller, sekolah: sekolah),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _confirmDelete(context, controller, sekolah),
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
        title: Text(isEdit ? "Edit Nama Sekolah" : "Tambah Sekolah Baru"),
        content: TextField(
          controller: controller.namaSekolahController,
          decoration: const InputDecoration(
            hintText: "Contoh: SMK Negeri 1 Jakarta",
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.namaSekolahController.clear();
              Get.back();
            },
            child: const Text("Batal"),
          ),
          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isEdit ? Colors.orange : Colors.green,
              foregroundColor: Colors.white,
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
      middleText: "Hapus sekolah '${sekolah['nama_sekolah']}'? Tindakan ini tidak dapat dibatalkan.",
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deleteSekolah(sekolah['id']);
        Get.back();
      },
    );
  }
}