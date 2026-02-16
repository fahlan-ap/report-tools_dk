import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SekolahController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  var isLoading = false.obs;

  // Variabel RxList untuk menampung data sekolah secara lokal
  var listSekolah = <Map<String, dynamic>>[].obs;

  // Controller untuk Input Text di Pop-up
  final TextEditingController namaSekolahController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchSekolah(); // Ambil data otomatis saat controller dimuat
  }

  // --- FUNGSI FETCH DATA (REFRESH) ---
  Future<void> fetchSekolah() async {
    try {
      isLoading.value = true;
      
      final response = await supabase
          .from('sekolah')
          .select('*')
          .order('nama_sekolah', ascending: true);

      // Konversi hasil ke List Map dan update RxList
      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
      listSekolah.value = data;

    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal mengambil data sekolah: $e",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi Tambah Sekolah
  Future<void> addSekolah() async {
    if (namaSekolahController.text.isEmpty) {
      Get.snackbar("Peringatan", "Nama Sekolah tidak boleh kosong");
      return;
    }

    try {
      isLoading.value = true;
      await supabase.from('sekolah').insert({
        'nama_sekolah': namaSekolahController.text,
      });

      namaSekolahController.clear();
      Get.back();
      
      // Refresh data agar list terupdate
      fetchSekolah();
      
      Get.snackbar(
        "Sukses",
        "Sekolah berhasil ditambahkan",
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal menambah sekolah: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi Edit Sekolah
  Future<void> updateSekolah(String id) async {
    if (namaSekolahController.text.isEmpty) {
      Get.snackbar("Peringatan", "Nama sekolah tidak boleh kosong");
      return;
    }

    try {
      isLoading.value = true;
      await supabase
          .from('sekolah')
          .update({'nama_sekolah': namaSekolahController.text})
          .eq('id', id);

      namaSekolahController.clear();
      Get.back();
      
      // Refresh data agar list terupdate
      fetchSekolah();

      Get.snackbar(
        "Sukses",
        "Data sekolah berhasil diperbarui",
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal memperbarui sekolah: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi Hapus Sekolah
  Future<void> deleteSekolah(String id) async {
    try {
      await supabase.from('sekolah').delete().eq('id', id);
      
      // Update list lokal secara langsung agar UI responsif
      listSekolah.removeWhere((item) => item['id'] == id);
      
      Get.snackbar("Sukses", "Sekolah berhasil dihapus");
    } catch (e) {
      Get.snackbar("Gagal", "Gagal menghapus sekolah: $e");
    }
  }

  @override
  void onClose() {
    namaSekolahController.dispose();
    super.onClose();
  }
}