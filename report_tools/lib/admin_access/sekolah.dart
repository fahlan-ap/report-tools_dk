import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sekolah_controller.dart';

class SekolahPage extends StatelessWidget {
  const SekolahPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller sekolah
    final controller = Get.put(SekolahController());

    return Column(
      children: [
        // --- HEADER HALAMAN ---
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
                "Daftar Sekolah",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showFormDialog(context, controller),
                icon: const Icon(Icons.add),
                label: const Text("Tambah"),
              ),
            ],
          ),
        ),

        // --- LIST DATA SEKOLAH (REAL-TIME) ---
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: controller.sekolahStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("Belum ada data sekolah."),
                );
              }

              final listSekolah = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: listSekolah.length,
                itemBuilder: (context, index) {
                  final sekolah = listSekolah[index];
                  return Card(
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
                        sekolah['nama_sekolah'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text("ID: ${sekolah['id'].toString().substring(0, 8)}..."),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tombol Edit
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                            onPressed: () => _showFormDialog(context, controller, sekolah: sekolah),
                          ),
                          // Tombol Hapus
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
            },
          ),
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