import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'user_service.dart';
import 'borrow_form.dart';
import '../widgets/loan_card.dart';
import 'profile.dart';

class UserDash extends StatefulWidget {
  const UserDash({super.key});

  @override
  State<UserDash> createState() => _UserDashState();
}

class _UserDashState extends State<UserDash> {
  final UserService _controller = UserService();

  // Variable untuk menyimpan nama (Default sementara "Karyawan")
  String _displayName = "Karyawan";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Fungsi ambil nama dari Database
  void _loadUserProfile() async {
    final profile = await _controller.getUserProfile();
    // Cek jika widget masih aktif (mounted) sebelum setState
    if (mounted && profile != null && profile['nama_lengkap'] != null) {
      setState(() {
        _displayName = profile['nama_lengkap'];
      });
    }
  }

  Future<void> _refreshData() async {
    _loadUserProfile();
    setState(() {}); // Refresh UI untuk memanggil ulang FutureBuilder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, $_displayName 👋",
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
            const Text(
              "Dashboard Inventaris",
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => Get.to(() => const ProfileScreen()),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.deepPurple, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.person, size: 24, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),

      // --- BODY UTAMA ---
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _controller.fetchDashboardData(),
          builder: (context, snapshot) {
            // 1. Loading State
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // 2. Error State
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final loans = snapshot.data ?? [];

            // 3. Empty State
            if (loans.isEmpty) return _buildEmptyState();

            // 4. List Data State
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: loans.length,
              itemBuilder: (context, index) {
                final loan = loans[index];

                // --- LOGIC PARSING DATA AMAN ---

                // Ambil Nama Sekolah
                final namaSekolah =
                    loan['sekolah'] != null
                        ? loan['sekolah']['nama_sekolah'] ?? 'Sekolah Dihapus'
                        : 'Sekolah Tidak Dikenal';

                // Ambil List Barang
                List<dynamic> details = loan['detail_peminjaman'] ?? [];

                String namaBarangDisplay;
                if (details.isEmpty) {
                  namaBarangDisplay = "Data barang tidak valid";
                } else {
                  // Mapping Aman: Cek apakah 'barang' tidak null
                  namaBarangDisplay = details
                      .map((d) {
                        if (d['barang'] != null) {
                          return d['barang']['nama_barang'].toString();
                        } else {
                          return 'Item Dihapus';
                        }
                      })
                      .join(", ");
                }

                // Parsing Tanggal
                final tgl = DateTime.parse(loan['waktu_pinjam']).toLocal();
                final tglDisplay = "${tgl.day}/${tgl.month}/${tgl.year}";

                return LoanCard(
                  itemName: namaBarangDisplay,
                  schoolName: namaSekolah,
                  date: tglDisplay,
                  status: loan['status'] ?? 'berlangsung',
                  isOverdue: false,

                  // Default false dulu
                );
              },
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navigasi ke Form, tunggu sampai user kembali, lalu refresh
          await Get.to(() => const BorrowForm());
          _refreshData();
        },
        label: const Text("Pinjam Baru"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 80,
                color: Colors.deepPurple.withOpacity(0.2),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Belum ada riwayat peminjaman.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
