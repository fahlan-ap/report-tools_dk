import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:report_tools/admin_access/barang.dart';
import 'package:report_tools/admin_access/sekolah.dart';
import 'package:report_tools/admin_access/user.dart';
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

  final List<Widget> _pages = [
    const ActivePeminjamanList(),
    const BarangPage(),
    const SekolahPage(),
    const UserPage(),
    const RiwayatPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Panel Administrasi",
              style: TextStyle(color: Colors.black87, fontSize: 12),
            ),
            Text(
              "Admin Dashboard",
              style: TextStyle(
                color: Colors.deepPurple, 
                fontWeight: FontWeight.bold, 
                fontSize: 18
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => authC.logout(),
            icon: const CircleAvatar(
              backgroundColor: Color(0xFFFFEBEE),
              child: Icon(Icons.logout, color: Colors.redAccent, size: 20),
            ),
            tooltip: "Logout",
          ),
          const SizedBox(width: 10),
        ],
      ),
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

class ActivePeminjamanList extends StatelessWidget {
  const ActivePeminjamanList({super.key});

  @override
  Widget build(BuildContext context) {
    final adminC = Get.put(DashController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Peminjaman Berlangsung",
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold,
                  color: Colors.black87
                ),
              ),
              IconButton(
                onPressed: () => adminC.fetchPeminjamanAktif(),
                icon: const Icon(Icons.refresh, color: Colors.deepPurple),
                tooltip: "Muat ulang data",
              ),
            ],
          ),
        ),

        // --- LIST DATA MENGGUNAKAN OBX ---
        Expanded(
          child: Obx(() {
            if (adminC.isLoading.value && adminC.listPeminjamanAktif.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
            }

            final data = adminC.listPeminjamanAktif;

            if (data.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined, 
                        size: 100, 
                        color: Colors.deepPurple.withOpacity(0.1)
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "tidak ada peminjaman alat inventaris yang berlangsung",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14, 
                          color: Colors.grey, 
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                
                final namaUser= item['profiles']?['nama_lengkap'] ?? 'User';
                final namaSekolah = item['sekolah']?['nama_sekolah'] ?? 'Sekolah';
                
                final List detailBarang = item['detail_peminjaman'] ?? [];
                final String semuaBarang = detailBarang.isEmpty 
                    ? "Tidak ada data barang" 
                    : detailBarang.map((d) => d['barang']['nama_barang']).join(', ');

                return Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12)
                              ),
                              child: const Icon(Icons.person, color: Colors.deepPurple, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                namaUser, 
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 15,
                                  color: Colors.black87
                                )
                              ),
                            ),
                            const Icon(Icons.timer_outlined, color: Colors.orange, size: 18),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, thickness: 0.5),
                        ),
                        _buildDetailRow(Icons.inventory_2_outlined, "Barang", semuaBarang),
                        const SizedBox(height: 8),
                        _buildDetailRow(Icons.school_outlined, "Tujuan", namaSekolah),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          Icons.access_time, 
                          "Waktu", 
                          item['waktu_pinjam'].toString().substring(0, 16).replaceAll('T', ' ')
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

  Widget _buildDetailRow(IconData icon, String label, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.deepPurple.withOpacity(0.5)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
              children: [
                TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }
}