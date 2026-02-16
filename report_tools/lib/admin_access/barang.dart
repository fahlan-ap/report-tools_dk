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
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Daftar Inventaris",
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

        // --- LIST DATA BARANG (REAL-TIME) ---
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: controller.barangStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("Belum ada data barang di gudang."),
                );
              }

              final listBarang = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: listBarang.length,
                itemBuilder: (context, index) {
                  final barang = listBarang[index];
                  return Card(
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
                        barang['nama_barang'],
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
            },
          ),
        ),
      ],
    );
  }

  // --- DIALOG FORM (TAMBAH & EDIT) ---
  void _showFormDialog(BuildContext context, BarangController controller, {Map? barang}) {
    // Jika ada data barang, berarti mode EDIT. Jika null, berarti mode TAMBAH.
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