import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_controller.dart';
import '../widgets/empty_state.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RiwayatController());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // --- HEADER ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Riwayat & Audit",
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

          // --- LIST RIWAYAT ---
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.groupedRiwayat.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
              }

              if (controller.groupedRiwayat.isEmpty) {
                return const EmptyState(message: "Belum ada riwayat aktivitas");
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: controller.groupedRiwayat.keys.length,
                itemBuilder: (context, index) {
                  String dateLabel = controller.groupedRiwayat.keys.elementAt(index);
                  List<Map<String, dynamic>> items = controller.groupedRiwayat[dateLabel]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateHeader(dateLabel),
                      ...items.map((item) => _buildRiwayatCard(item)).toList(),
                      const SizedBox(height: 15),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Header Tanggal (Sticky-like label)
  Widget _buildDateHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 10, top: 5),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800, 
              color: Colors.deepPurple,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // Card Riwayat Compact dengan ExpansionTile
  Widget _buildRiwayatCard(Map<String, dynamic> item) {
    String jam = item['waktu_kembali'] != null 
        ? item['waktu_kembali'].toString().substring(11, 16) 
        : "-";

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: Colors.deepPurple,
          collapsedIconColor: Colors.grey,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          leading: const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFFE8F5E9),
            child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
          ),
          title: Text(
            item['nama_user'] ?? "User",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            "${item['nama_sekolah']} • $jam WIB",
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 20),
                  _buildDetailRow(Icons.inventory_2_outlined, "Barang", item['nama_barang'] ?? "-"),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (item['foto_pinjam'] != null)
                        Expanded(child: _buildPhotoBox("Foto Pinjam", item['foto_pinjam'])),
                      if (item['foto_pinjam'] != null && item['foto_kembali'] != null)
                        const SizedBox(width: 10),
                      if (item['foto_kembali'] != null)
                        Expanded(child: _buildPhotoBox("Foto Kembali", item['foto_kembali'])),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoBox(String label, String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            url, 
            height: 90, 
            width: double.infinity, 
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(height: 90, color: Colors.grey.shade100, child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))));
            },
            errorBuilder: (_, __, ___) => Container(
              height: 90, 
              width: double.infinity,
              color: Colors.grey.shade100, 
              child: const Icon(Icons.broken_image_rounded, color: Colors.grey, size: 24)
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRefreshButton(RiwayatController controller) {
    return InkWell(
      onTap: () => controller.fetchRiwayat(),
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
}