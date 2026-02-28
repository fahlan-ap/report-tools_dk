import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authC = Get.find<AuthController>();
    final UserController controller = Get.find<UserController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Background konsisten
      appBar: AppBar(
        title: const Text(
          "Profil Saya",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2D2D2D),
        actions: [
          IconButton(
            onPressed: () => controller.fetchUserProfile(),
            icon: const Icon(Icons.refresh_rounded),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.userProfile.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
        }

        final profile = controller.userProfile;
        final String nama = profile['nama_lengkap'] ?? "Nama Tidak Tersedia";
        final String nip = profile['nip'] ?? "-";

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              // --- HEADER PROFILE (MODERN) ---
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.deepPurple,
                        child: Icon(Icons.person_rounded, size: 50, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2D2D2D),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "TEACHER / USER",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.deepPurple,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // --- INFO DETAIL (COMPACT CARDS) ---
              _buildProfileCard(
                icon: Icons.badge_rounded,
                label: "Nomor Induk Pegawai (NIP)",
                value: nip,
                accentColor: Colors.blue,
              ),

              _buildProfileCard(
                icon: Icons.alternate_email_rounded,
                label: "Email Akun",
                value: authC.supabase.auth.currentUser?.email ?? "-",
                accentColor: Colors.orange,
              ),

              const SizedBox(height: 40),

              // --- TOMBOL LOGOUT (MODERN) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    onPressed: () => _confirmLogout(authC),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.red.shade50, width: 2),
                      ),
                    ),
                    label: const Text(
                      "Keluar dari Aplikasi",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              Text(
                "Versi 1.0.0",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.bold),
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
    required Color accentColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: accentColor, size: 22),
        ),
        title: Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D2D2D),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(AuthController authC) {
    Get.defaultDialog(
      title: "Konfirmasi Keluar",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: "Anda yakin ingin mengakhiri sesi ini?",
      textConfirm: "Ya, Keluar",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () => authC.logout(),
    );
  }
}