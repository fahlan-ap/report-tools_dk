import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import 'borrow_form.dart';
import 'return_form.dart'; 
import '../widgets/loan_card.dart';
import '../widgets/empty_state.dart'; // Menggunakan widget yang sama dengan admin
import 'profile.dart';

class UserDash extends StatelessWidget {
  const UserDash({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi Controller
    final UserController controller = Get.put(UserController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Background cerah & modern
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 90, // Disamakan dengan Admin Dash
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Obx(() {
            final displayName = controller.userProfile['nama_lengkap'] ?? "User";
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, $displayName 👋",
                  style: TextStyle(
                    color: Colors.grey.shade600, 
                    fontSize: 13, 
                    letterSpacing: 0.5
                  ),
                ),
                const Text(
                  "Dashboard Inventaris",
                  style: TextStyle(
                    color: Color(0xFF2D2D2D), 
                    fontWeight: FontWeight.w900, 
                    fontSize: 15
                  ),
                ),
              ],
            );
          }),
        ),
        actions: [
          // Profile Button Modern
          Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: IconButton(
              onPressed: () => Get.to(() => const ProfileScreen()),
              icon: const Icon(Icons.person_outline_rounded, color: Colors.deepPurple, size: 24),
              tooltip: "Profil",
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchUserDashboard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 5),
              child: Text(
                "Peminjaman Berlangsung",
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2D2D2D)
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.listPeminjamanAktif.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                }

                if (controller.listPeminjamanAktif.isEmpty) {
                  return const EmptyState(message: "Tidak ada peminjaman aktif");
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: controller.listPeminjamanAktif.length,
                  itemBuilder: (context, index) {
                    final Map<String, dynamic> loan = controller.listPeminjamanAktif[index];

                    // Parsing Data UI
                    final namaSekolah = loan['sekolah']?['nama_sekolah'] ?? 'Sekolah';
                    final List<dynamic> details = loan['detail_peminjaman'] ?? [];
                    final String namaBarangDisplay = details.isEmpty 
                        ? "Tanpa Item" 
                        : details.map((d) => d['barang']?['nama_barang'] ?? 'Item').join(", ");

                    final String tglRaw = loan['waktu_pinjam'] ?? "";
                    final String tglDisplay = tglRaw.length >= 10 
                        ? tglRaw.substring(0, 10).split('-').reversed.join('/') 
                        : "-";

                    return LoanCard(
                      itemName: namaBarangDisplay,
                      schoolName: namaSekolah,
                      date: tglDisplay,
                      status: loan['status'] ?? 'berlangsung',
                      isOverdue: false, 
                      onTap: () => Get.to(() => ReturnForm(loanData: loan)),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      // Floating Action Button yang dirampingkan (Sama dengan Admin Dash)
      floatingActionButton: Positioned(
        bottom: 20,
        right: 20,
        child: SizedBox(
          height: 50,
          child: FloatingActionButton.extended(
            onPressed: () => Get.to(() => const BorrowForm()),
            label: const Text("Pinjam Baru", style: TextStyle(fontWeight: FontWeight.bold)),
            icon: const Icon(Icons.add_rounded),
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
        ),
      ),
    );
  }
}