import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_controller.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller khusus riwayat
    final controller = Get.put(RiwayatController());

    return Column(
      children: [
        // --- HEADER HALAMAN (Disamakan dengan Barang, Sekolah, User) ---
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Riwayat & Audit",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Tombol Refresh diletakkan di kanan seperti halaman lainnya
              IconButton(
                onPressed: () => controller.fetchRiwayat(),
                icon: const Icon(Icons.refresh, color: Colors.deepPurple),
                tooltip: "Muat ulang data",
              ),
            ],
          ),
        ),

        // --- LIST DATA RIWAYAT ---
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.groupedRiwayat.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
            }

            if (controller.groupedRiwayat.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_outlined, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text("Belum ada data riwayat tersedia", 
                      style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8), // Memberi sedikit ruang
              itemCount: controller.groupedRiwayat.keys.length,
              itemBuilder: (context, index) {
                String dateLabel = controller.groupedRiwayat.keys.elementAt(index);
                List<Map<String, dynamic>> items = controller.groupedRiwayat[dateLabel]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER TANGGAL ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Text(
                        dateLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: Colors.deepPurple,
                          fontSize: 13
                        ),
                      ),
                    ),

                    // --- DAFTAR ITEM RIWAYAT ---
                    ...items.map((item) {
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0.5,
                        child: ExpansionTile(
                          shape: const RoundedRectangleBorder(side: BorderSide.none), // Menghilangkan garis border default
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE8F5E9),
                            child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                          ),
                          title: Text(
                            item['nama_karyawan'] ?? "Tanpa Nama",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Text(
                            "${item['nama_sekolah']} • ${item['waktu_kembali'].toString().substring(11, 16)}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  _buildDetailRow("Barang", item['nama_barang'] ?? "-"),
                                  const SizedBox(height: 12),
                                  
                                  // Tampilan Foto
                                  Row(
                                    children: [
                                      if (item['foto_pinjam'] != null)
                                        Expanded(child: _buildPhotoPreview("Foto Pinjam", item['foto_pinjam'])),
                                      const SizedBox(width: 8),
                                      if (item['foto_kembali'] != null)
                                        Expanded(child: _buildPhotoPreview("Foto Kembali", item['foto_kembali'])),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            );
          }),
        ),
      ],
    );
  }

  // Widget Pembantu Detail
  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // Widget Pembantu Preview Foto
  Widget _buildPhotoPreview(String label, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            url,
            height: 100,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => 
              Container(
                height: 100, 
                color: Colors.grey.shade200, 
                child: const Icon(Icons.broken_image, color: Colors.grey)
              ),
          ),
        ),
      ],
    );
  }
}