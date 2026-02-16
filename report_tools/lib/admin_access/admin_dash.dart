import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:report_tools/admin_access/barang.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dash_controller.dart';
import '../components/custom_bottom_nav.dart';
import 'riwayat.dart';

class AdminDash extends StatefulWidget {
  const AdminDash({super.key});

  @override
  State<AdminDash> createState() => _AdminDashState();
}

class _AdminDashState extends State<AdminDash> {
  final authC = Get.find<AuthController>();
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan di area body
  final List<Widget> _pages = [
    const ActivePeminjamanList(),
    const BarangPage(),
    const Center(child: Text("Halaman Kontrol Sekolah")),
    const Center(child: Text("Halaman Kontrol Karyawan")),
    const RiwayatPage(), // Memanggil fitur riwayat yang sudah dipisah
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => authC.logout(),
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          )
        ],
      ),
      // Body akan berganti sesuai index, tapi BottomNav tetap menetap
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

// Bagian ActivePeminjamanList tetap sama seperti kode Anda sebelumnya
class ActivePeminjamanList extends StatelessWidget {
  const ActivePeminjamanList({super.key});

  @override
  Widget build(BuildContext context) {
    final adminC = Get.put(DashController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            "Peminjaman Berlangsung",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: adminC.getDetailedPeminjaman(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data ?? [];

              if (data.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 100, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          "tidak ada peminjaman alat inventaris yang berlangsung",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  final namaKaryawan = item['profiles']?['nama_lengkap'] ?? 'User';
                  final namaBarang = item['barang']?['nama_barang'] ?? 'Barang';
                  final namaSekolah = item['sekolah']?['nama_sekolah'] ?? 'Sekolah';

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(namaKaryawan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const Icon(Icons.more_horiz),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          _buildDetailRow(Icons.inventory, "Barang: $namaBarang"),
                          _buildDetailRow(Icons.school, "Tujuan: $namaSekolah"),
                          _buildDetailRow(Icons.calendar_today, "Waktu: ${item['waktu_pinjam']}"),
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

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}