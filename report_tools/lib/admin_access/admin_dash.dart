import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:report_tools/admin_access/barang.dart';
import 'package:report_tools/admin_access/sekolah.dart';
import 'package:report_tools/admin_access/user.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dash_controller.dart';
import '../components/custom_bottom_nav.dart';
import '../widgets/modern_card.dart'; // Widget yang sudah dipisah
import '../widgets/empty_state.dart'; // Widget yang sudah dipisah
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
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Panel Administrasi",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const Text(
                "Admin Dashboard",
                style: TextStyle(
                  color: Color(0xFF2D2D2D),
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        actions: [
          _buildLogoutButton(),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () => _confirmLogout(),
        icon: const Icon(
          Icons.logout_rounded,
          color: Colors.redAccent,
          size: 22,
        ),
        tooltip: "Logout",
      ),
    );
  }

  void _confirmLogout() {
    Get.defaultDialog(
      title: "Konfirmasi Keluar",
      titleStyle: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 18,
        color: Color.fromARGB(255, 27, 10, 10),
      ),
      middleText: "Anda yakin ingin Logout dari sesi Admin?",
      middleTextStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
      textConfirm: "Keluar",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      cancelTextColor: Colors.grey,
      radius: 20,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      onConfirm: () {
        Get.back();
        authC.logout();
      },
    );
  }
}

class ActivePeminjamanList extends StatelessWidget {
  const ActivePeminjamanList({super.key});

  @override
  Widget build(BuildContext context) {
    // Memastikan Controller terinisialisasi
    final adminC = Get.put(DashController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(adminC),
        Expanded(
          child: Obx(() {
            if (adminC.isLoading.value && adminC.listPeminjamanAktif.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.deepPurple),
              );
            }

            if (adminC.listPeminjamanAktif.isEmpty) {
              return const EmptyState(
                message: "Tidak ada peminjaman berlangsung",
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: adminC.listPeminjamanAktif.length,
              itemBuilder: (context, index) {
                final item = adminC.listPeminjamanAktif[index];

                // Parsing Data
                final namaUser = item['profiles']?['nama_lengkap'] ?? 'User';
                final namaSekolah =
                    item['sekolah']?['nama_sekolah'] ?? 'Sekolah';
                final List detail = item['detail_peminjaman'] ?? [];
                final String barang = detail.isEmpty
                    ? "Tanpa data barang"
                    : detail.map((d) => d['barang']['nama_barang']).join(', ');
                final String waktu = item['waktu_pinjam']
                    .toString()
                    .substring(0, 16)
                    .replaceAll('T', ' ');

                return ModernCard(
                  user: namaUser,
                  barang: barang,
                  sekolah: namaSekolah,
                  waktu: waktu,
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHeader(DashController adminC) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Peminjaman Aktif",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2D2D2D),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => adminC.fetchPeminjamanAktif(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Colors.deepPurple,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
