import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/barang_controller.dart';

class BarangPage extends StatelessWidget {
  const BarangPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller
    final controller = Get.put(BarangController());

    return Column(
      children: [
        // --- HEADER HALAMAN ---
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Daftar Inventaris",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Menggabungkan tombol Tambah dan Refresh dalam Row
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
                  const SizedBox(width: 8), // Jarak antar tombol
                  // TOMBOL REFRESH
                  IconButton(
                    onPressed: () => controller.fetchBarang(),
                    icon: const Icon(Icons.refresh, color: Colors.deepPurple),
                    tooltip: "Muat ulang data",
                  ),
                ],
              ),
            ],
          ),
        ),

        // --- LIST DATA BARANG (MENGGUNAKAN OBX) ---
        Expanded(
          child: Obx(() {
            // Tampilkan loading jika data sedang diambil dan list masih kosong
            if (controller.isLoading.value && controller.listBarang.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
            }

            // Jika data kosong
            if (controller.listBarang.isEmpty) {
              return const Center(
                child: Text("Belum ada data barang di inventaris."),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.listBarang.length,
              itemBuilder: (context, index) {
                final barang = controller.listBarang[index];
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: const Icon(Icons.inventory_2, color: Colors.blue),
                    ),
                    title: Text(
                      barang['nama_barang'] ?? "-",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text("ID: ${barang['id'].toString().substring(0, 8)}..."),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tombol Edit
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.orange),
                          onPressed: () => _showFormDialog(context, controller, barang: barang),
                        ),
                        // Tombol Hapus
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _confirmDelete(context, controller, barang),
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
  void _showFormDialog(BuildContext context, BarangController controller, {Map? barang}) {
    bool isEdit = barang != null;
    
    if (isEdit) {
      controller.namaBarangController.text = barang['nama_barang'];
    } else {
      controller.namaBarangController.clear();
    }

    Get.dialog(
      AlertDialog(
        title: Text(isEdit ? "Edit Nama Barang" : "Tambah Barang Baru"),
        content: TextField(
          controller: controller.namaBarangController,
          decoration: const InputDecoration(
            hintText: "Contoh: Laptop Asus VivoBook",
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.namaBarangController.clear();
              Get.back();
            },
            child: const Text("Batal"),
          ),
          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isEdit ? Colors.orange : Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: controller.isLoading.value 
                ? null 
                : () => isEdit ? controller.updateBarang(barang['id']) : controller.addBarang(),
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
  void _confirmDelete(BuildContext context, BarangController controller, Map barang) {
    Get.defaultDialog(
      title: "Hapus Barang",
      middleText: "Apakah Anda yakin ingin menghapus '${barang['nama_barang']}'? Tindakan ini tidak dapat dibatalkan.",
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deleteBarang(barang['id']);
        Get.back();
      },
    );
  }
}