import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_controller.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RiwayatController());

    return Column(
      children: [
        // --- HEADER ---
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Riwayat & Audit",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => controller.fetchRiwayat(),
                icon: const Icon(Icons.refresh, color: Colors.deepPurple),
              ),
            ],
          ),
        ),

        // --- LIST RIWAYAT ---
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.groupedRiwayat.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
            }

            if (controller.groupedRiwayat.isEmpty) {
              return const Center(child: Text("Belum ada data riwayat"));
            }

            return ListView.builder(
              itemCount: controller.groupedRiwayat.keys.length,
              itemBuilder: (context, index) {
                String dateLabel = controller.groupedRiwayat.keys.elementAt(index);
                List<Map<String, dynamic>> items = controller.groupedRiwayat[dateLabel]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Text(
                        dateLabel,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                    ),

                    ...items.map((item) {
                      String jam = "-";
                      if (item['waktu_kembali'] != null) {
                        jam = item['waktu_kembali'].toString().substring(11, 16);
                      }

                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ExpansionTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE8F5E9),
                            child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                          ),
                          title: Text(
                            item['nama_user'] ?? "Tanpa Nama",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("${item['nama_sekolah']} • $jam"),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  _buildDetailRow("Daftar Barang", item['nama_barang'] ?? "-"),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      if (item['foto_pinjam'] != null)
                                        Expanded(child: _buildPhotoBox("Foto Pinjam", item['foto_pinjam'])),
                                      const SizedBox(width: 8),
                                      if (item['foto_kembali'] != null)
                                        Expanded(child: _buildPhotoBox("Foto Kembali", item['foto_kembali'])),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildPhotoBox(String label, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(url, height: 100, width: double.infinity, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(height: 100, color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
          ),
        ),
      ],
    );
  }
}