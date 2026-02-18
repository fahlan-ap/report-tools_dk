import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import 'borrow_form.dart';
import 'return_form.dart'; 
import '../widgets/loan_card.dart';
import 'profile.dart';

class UserDash extends StatelessWidget {
  const UserDash({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi Controller
    final UserController controller = Get.put(UserController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Obx(() {
          final displayName = controller.userProfile['nama_lengkap'] ?? "User";
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Halo, $displayName 👋",
                style: const TextStyle(color: Colors.black87, fontSize: 14)),
              const Text("Dashboard Inventaris",
                style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          );
        }),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const ProfileScreen()),
            icon: const CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchUserDashboard(),
        child: Obx(() {
          if (controller.isLoading.value && controller.listPeminjamanAktif.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
          }

          final loans = controller.listPeminjamanAktif;

          if (loans.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: loans.length,
            itemBuilder: (context, index) {
              final Map<String, dynamic> loan = loans[index];

              // Parsing Data UI
              final namaSekolah = loan['sekolah']?['nama_sekolah'] ?? 'Sekolah Tidak Diketahui';
              final List<dynamic> details = loan['detail_peminjaman'] ?? [];
              final String namaBarangDisplay = details.isEmpty 
                  ? "Tanpa Item" 
                  : details.map((d) => d['barang']?['nama_barang'] ?? 'Item Dihapus').join(", ");

              final String tglRaw = loan['waktu_pinjam'] ?? "";
              final String tglDisplay = tglRaw.length >= 10 
                  ? tglRaw.substring(0, 10).split('-').reversed.join('/') 
                  : "-";

              return GestureDetector(
                onTap: () => Get.to(() => ReturnForm(loanData: loan)),
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
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const BorrowForm()),
        label: const Text("Pinjam Baru"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Icon(Icons.inventory_2_outlined, 
                size: 80, 
                color: Colors.deepPurple.withOpacity(0.1)
              ),
              const SizedBox(height: 16),
              const Text("Tidak ada peminjaman aktif", 
                style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Data yang dikembalikan akan pindah ke riwayat.", 
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}