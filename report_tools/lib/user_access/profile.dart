import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController _authC = Get.find<AuthController>();
  final UserService _controller = UserService();

  // Data Profil
  String _nama = "Memuat...";
  String _role = "-";
  String _nip = "-";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final data = await _controller.getUserProfile();
    if (mounted) {
      setState(() {
        if (data != null) {
          _nama = data['nama_lengkap'] ?? "Tanpa Nama";
          _role = data['role'] ?? "Staff";
          _nip = data['nip'] ?? "-";
        } else {
          _nama = "Data tidak ditemukan";
        }
        _isLoading = false;
      });
    }
  }

  // --- LOGIKA GANTI PASSWORD ---
  void _showChangePasswordDialog() {
    final TextEditingController passController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool isObscure = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Ganti Password"),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Masukkan password baru anda."),
                    const SizedBox(height: 16),

                    // Input Password Baru
                    TextFormField(
                      controller: passController,
                      obscureText: isObscure,
                      decoration: InputDecoration(
                        labelText: "Password Baru",
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.deepPurple,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isObscure ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed:
                              () =>
                                  setStateDialog(() => isObscure = !isObscure),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return "Minimal 6 karakter";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Input Konfirmasi Password
                    TextFormField(
                      controller: confirmController,
                      obscureText: isObscure,
                      decoration: InputDecoration(
                        labelText: "Ulangi Password",
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.deepPurple,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value != passController.text) {
                          return "Password tidak sama";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Batal",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      try {
                        // Panggil fungsi di ControllerService
                        await _controller.updatePassword(passController.text);

                        Navigator.pop(context); // Tutup Dialog
                        Get.snackbar(
                          "Sukses",
                          "Password berhasil diperbarui!",
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      } catch (e) {
                        Get.snackbar(
                          "Gagal",
                          "Terjadi kesalahan: $e",
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    }
                  },
                  child: const Text(
                    "Simpan",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: const Text("Profil Saya"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                            _nama,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$_role  |  NIP: $_nip",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- MENU OPTIONS (Edit Data Diri SUDAH DIHAPUS) ---

                    // Menu Ganti Password (Sekarang ada fungsinya)
                    _buildProfileMenu(
                      icon: Icons.lock_outline,
                      title: "Ganti Password",
                      onTap: _showChangePasswordDialog, // Panggil fungsi dialog
                    ),

                    const SizedBox(height: 20),

                    // --- TOMBOL LOGOUT ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _authC.logout(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Keluar Aplikasi"),
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
              ),
    );
  }

  Widget _buildProfileMenu({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
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
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.deepPurple),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
