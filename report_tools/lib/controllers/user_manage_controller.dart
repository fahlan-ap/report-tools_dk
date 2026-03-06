import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserManageController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  var isLoading = false.obs;

  var listUser = <Map<String, dynamic>>[].obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController namaController = TextEditingController();
  final TextEditingController nipController = TextEditingController();

  String? tempUid; 

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      
      final response = await supabase
          .from('profiles')
          .select('*')
          .eq('role', 'user')
          .order('nama_lengkap', ascending: true);

      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
      listUser.value = data;

    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data user: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createAuthAccount() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Peringatan", "Email dan Password wajib diisi");
      return false;
    }

    try {
      isLoading.value = true;
      
      final AuthResponse res = await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (res.user != null) {
        tempUid = res.user!.id;
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

  Future<void> saveProfile() async {
    if (tempUid == null) return;

    if (namaController.text.isEmpty || nipController.text.isEmpty) {
      Get.snackbar("Peringatan", "Nama dan NIP wajib diisi");
      return;
    }

    try {
      isLoading.value = true;
      await supabase.from('profiles').insert({
        'id': tempUid, 
        'nama_lengkap': namaController.text,
        'nip': nipController.text,
        'role': 'user', 
      });

      _clearAll();
      Get.back();
      
      fetchUsers();
      
      Get.snackbar("Sukses", "Akun dan Profil berhasil dibuat");
    } catch (e) {
      Get.snackbar("Profile Error", "Gagal menyimpan data profil: $e");
    } finally {
      isLoading.value = false;
    }
  }

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
      
      fetchUsers();
      
      Get.snackbar("Sukses", "Data user berhasil diperbarui");
    } catch (e) {
      Get.snackbar("Error", "Gagal memperbarui data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await supabase.from('profiles').delete().eq('id', id);
      
      listUser.removeWhere((user) => user['id'] == id);
      
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