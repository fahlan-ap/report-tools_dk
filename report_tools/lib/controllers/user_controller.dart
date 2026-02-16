import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  var isLoading = false.obs;

  // Controllers untuk Akun Login (Auth)
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Controllers untuk Data Profil (Profiles)
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nipController = TextEditingController();

  // Variabel penampung UUID sementara dari Auth
  String? tempUid; 

  // Stream data khusus user (filter role: user)
  Stream<List<Map<String, dynamic>>> get userStream {
    return supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('role', 'user')
        .order('nama_lengkap', ascending: true);
  }

  // --- LANGKAH 1: Membuat Akun Auth ---
  Future<bool> createAuthAccount() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Peringatan", "Email dan Password wajib diisi");
      return false;
    }

    try {
      isLoading.value = true;
      
      // Mendaftarkan akun ke sistem Autentikasi Supabase
      final AuthResponse res = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (res.user != null) {
        tempUid = res.user!.id; // Menangkap UUID unik untuk relasi profiles
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar("Auth Error", "Gagal membuat akun: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // --- LANGKAH 2: Mengisi Data Profiles ---
  Future<void> saveProfile() async {
    if (tempUid == null) {
      Get.snackbar("Error", "ID User tidak ditemukan. Ulangi langkah pertama.");
      return;
    }

    if (namaController.text.isEmpty || nipController.text.isEmpty) {
      Get.snackbar("Peringatan", "Nama dan NIP wajib diisi");
      return;
    }

    try {
      isLoading.value = true;
      // Memasukkan data ke tabel profiles menggunakan UUID dari Auth
      await supabase.from('profiles').insert({
        'id': tempUid, 
        'nama_lengkap': namaController.text,
        'nip': nipController.text, //
        'role': 'user', //
      });

      _clearAll();
      Get.back(); // Menutup dialog profil
      Get.snackbar("Sukses", "Akun dan Profil berhasil dibuat");
    } catch (e) {
      Get.snackbar("Profile Error", "Gagal menyimpan data profil: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi Update User (Hanya Profil)
  Future<void> updateUser(String id) async {
    if (namaController.text.isEmpty || nipController.text.isEmpty) {
      Get.snackbar("Peringatan", "Data tidak boleh kosong");
      return;
    }

    try {
      isLoading.value = true;
      await supabase.from('profiles').update({
        'nama_lengkap': namaController.text,
        'nip': nipController.text,
      }).eq('id', id);

      _clearAll();
      Get.back();
      Get.snackbar("Sukses", "Data user berhasil diperbarui");
    } catch (e) {
      Get.snackbar("Error", "Gagal memperbarui data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi Hapus User (Menghapus profil, namun akun Auth tetap ada di Supabase Auth)
  Future<void> deleteUser(String id) async {
    try {
      await supabase.from('profiles').delete().eq('id', id);
      Get.snackbar("Sukses", "User berhasil dihapus");
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus user: $e");
    }
  }

  void _clearAll() {
    emailController.clear();
    passwordController.clear();
    namaController.clear();
    nipController.clear();
    tempUid = null;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    namaController.dispose();
    nipController.dispose();
    super.onClose();
  }
}