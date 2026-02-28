import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/barang_controller.dart';
import '../widgets/empty_state.dart';

class BarangPage extends StatelessWidget {
  const BarangPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisiasi Controller
    final controller = Get.put(BarangController());

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
                      "Daftar Inventaris",
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

              // --- LIST DATA BARANG (MENGGUNAKAN OBX) ---
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.listBarang.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                  }

                  if (controller.listBarang.isEmpty) {
                    return const EmptyState(message: "Belum ada data barang di inventaris");
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100), // Padding bawah untuk FAB
                    itemCount: controller.listBarang.length,
                    itemBuilder: (context, index) {
                      final barang = controller.listBarang[index];
                      return _buildBarangCard(context, controller, barang);
                    },
                  );
                }),
              ),
            ],
          ),

          // --- FLOATING ACTION BUTTON (MANUAL POSITION) ---
          Positioned(
            bottom: 20,
            right: 20,
            child: SizedBox(
              height: 50,
              child: FloatingActionButton.extended(
                onPressed: () => _showFormDialog(context, controller),
                elevation: 2,
                extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
                label: const Text("Tambah", style: TextStyle(fontWeight: FontWeight.bold,)),
                icon: const Icon(Icons.add_rounded),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            )
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: CARD BARANG ---
  Widget _buildBarangCard(BuildContext context, BarangController controller, Map barang) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), // Margin antar card dipersempit
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Lebih ramping
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        dense: true, // Membuat ListTile lebih compact secara otomatis
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        leading: Container(
          padding: const EdgeInsets.all(8), // Padding icon diperkecil
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.inventory_2_rounded, color: Colors.blue, size: 20),
        ),
        title: Text(
          barang['nama_barang'] ?? "-",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), // Font dikecilkan
        ),
        subtitle: Text(
          "ID: ${barang['id'].toString().toUpperCase().substring(0, 8)}",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionIcon(
              icon: Icons.edit_note_rounded,
              color: Colors.orange,
              onTap: () => _showFormDialog(context, controller, barang: barang),
            ),
            const SizedBox(width: 4), // Jarak antar tombol dipersempit
            _buildActionIcon(
              icon: Icons.delete_sweep_rounded,
              color: Colors.redAccent,
              onTap: () => _confirmDelete(context, controller, barang),
            ),
          ],
        ),
      ),
    );
  }

  // Sesuaikan juga ukuran action icon agar tidak terlalu besar
  Widget _buildActionIcon({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6), // Padding tombol aksi diperkecil
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18), // Icon diperkecil
      ),
    );
  }

  Widget _buildRefreshButton(BarangController controller) {
    return InkWell(
      onTap: () => controller.fetchBarang(),
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
  void _showFormDialog(BuildContext context, BarangController controller, {Map? barang}) {
    bool isEdit = barang != null;
    
    if (isEdit) {
      controller.namaBarangController.text = barang['nama_barang'];
    } else {
      controller.namaBarangController.clear();
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEdit ? "Edit Nama Barang" : "Tambah Barang Baru",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller.namaBarangController,
              decoration: InputDecoration(
                labelText: "Nama Barang",
                prefixIcon: const Icon(Icons.edit_note_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.namaBarangController.clear();
              Get.back();
            },
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          Obx(() => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isEdit ? Colors.orange : Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: "Yakin ingin menghapus '${barang['nama_barang']}'?",
      textConfirm: "Ya, Hapus",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        controller.deleteBarang(barang['id']);
        Get.back();
      },
    );
  }
}