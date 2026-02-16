import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/riwayat_controller.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller khusus riwayat
    final controller = Get.put(RiwayatController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Audit Mingguan"),
        actions: [
          IconButton(
            onPressed: () => controller.fetchRiwayat(),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.groupedRiwayat.isEmpty) {
          return const Center(
            child: Text("Belum ada data riwayat untuk minggu ini"),
          );
        }

        return ListView.builder(
          itemCount: controller.groupedRiwayat.keys.length,
          itemBuilder: (context, index) {
            String date = controller.groupedRiwayat.keys.elementAt(index);
            List<Map<String, dynamic>> items = controller.groupedRiwayat[date]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Tanggal
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey.shade200,
                  child: Text(
                    date,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                ),
                // Daftar Peminjaman pada tanggal tersebut
                ...items.map((item) {
                  // Ambil nama barang dari relasi detail_peminjaman
                  final listBarang = (item['detail_peminjaman'] as List)
                      .map((d) => d['barang']['nama_barang'])
                      .join(', ');

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.history_edu, color: Colors.green),
                      title: Text(item['profiles']['nama_lengkap'] ?? "Tanpa Nama"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Barang: $listBarang"),
                          Text("Sekolah: ${item['sekolah']['nama_sekolah']}"),
                          Text(
                            "Kembali: ${item['waktu_kembali'].toString().substring(11, 16)}",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                }),
              ],
            );
          },
        );
      }),
    );
  }
}