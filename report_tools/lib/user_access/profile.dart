import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi Controller
    final AuthController authC = Get.find<AuthController>();
    final UserController controller = Get.find<UserController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: const Text("Profil Saya"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: () => controller.fetchUserProfile(),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.userProfile.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = controller.userProfile;
        final String nama = profile['nama_lengkap'] ?? "Data tidak ditemukan";
        final String nip = profile['nip'] ?? "-";

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              // --- HEADER PROFILE ---
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.deepPurple,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "TEACHER / USER",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // --- INFO DETAIL ---
              _buildProfileCard(
                icon: Icons.badge_outlined,
                label: "NIP",
                value: nip,
              ),

              _buildProfileCard(
                icon: Icons.email_outlined,
                label: "Email Akun",
                value: authC.supabase.auth.currentUser?.email ?? "-",
              ),

              const SizedBox(height: 40),

              // --- TOMBOL LOGOUT ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      Get.defaultDialog(
                        title: "Konfirmasi Keluar",
                        middleText: "Anda yakin ingin keluar dari aplikasi?",
                        textConfirm: "Ya, Keluar",
                        textCancel: "Batal",
                        confirmTextColor: Colors.white,
                        buttonColor: Colors.red,
                        onConfirm: () => authC.logout(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red.shade100),
                      ),
                    ),
                    label: const Text(
                      "Keluar Aplikasi",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                "Versi Aplikasi 1.0.0",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.deepPurple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}