import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'user_service.dart';
import 'borrow_form.dart';
import 'return_form.dart'; 
import '../widgets/loan_card.dart';
import 'profile.dart';

class UserDash extends StatefulWidget {
  const UserDash({super.key});

  @override
  State<UserDash> createState() => _UserDashState();
}

class _UserDashState extends State<UserDash> {
  final UserService _controller = UserService();
  String _displayName = "Karyawan";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await _controller.getUserProfile();
    if (mounted && profile != null) {
      setState(() {
        _displayName = profile['nama_lengkap'] ?? "Karyawan";
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadUserProfile();
    setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Halo, $_displayName 👋",
              style: const TextStyle(color: Colors.black87, fontSize: 14)),
            const Text("Dashboard Inventaris",
              style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Get.to(() => const ProfileScreen());
              _loadUserProfile();
            },
            icon: const CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _controller.fetchDashboardData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
            }

            final loans = snapshot.data ?? [];
            if (loans.isEmpty) return _buildEmptyState();

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: loans.length,
              itemBuilder: (context, index) {
                // MENGAMBIL VARIABEL LOAN UTUH DARI SNAPSHOT
                final Map<String, dynamic> loan = loans[index];

                // Parsing UI Display
                final namaSekolah = loan['sekolah']?['nama_sekolah'] ?? 'Sekolah Tidak Diketahui';
                final List<dynamic> details = loan['detail_peminjaman'] ?? [];
                final String namaBarangDisplay = details.isEmpty 
                    ? "Tanpa Item" 
                    : details.map((d) => d['barang']?['nama_barang'] ?? 'Item Dihapus').join(", ");

                final DateTime? tglRaw = loan['waktu_pinjam'] != null 
                    ? DateTime.parse(loan['waktu_pinjam']).toLocal() 
                    : null;
                final String tglDisplay = tglRaw != null 
                    ? "${tglRaw.day}/${tglRaw.month}/${tglRaw.year}" 
                    : "-";

                return GestureDetector(
                  onTap: () async {
                    // MENGIRIM VARIABEL 'loan' SECARA UTUH KE RETURNFORM
                    await Get.to(() => ReturnForm(loanData: loan));
                    // Setelah kembali dari form pengembalian, refresh data agar card menghilang
                    _refreshData();
                  },
                  child: LoanCard(
                    itemName: namaBarangDisplay,
                    schoolName: namaSekolah,
                    date: tglDisplay,
                    status: loan['status'] ?? 'berlangsung',
                    isOverdue: false, 
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
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
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined, size: 80, color: Colors.deepPurple.withOpacity(0.2)),
              const SizedBox(height: 16),
              const Text("Tidak ada peminjaman aktif", style: TextStyle(color: Colors.grey, fontSize: 16)),
              const Text("Data yang dikembalikan akan pindah ke riwayat.", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}