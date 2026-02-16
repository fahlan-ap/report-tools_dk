import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BarangController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  var isLoading = false.obs;

  // Variabel RxList untuk menampung data barang secara lokal
  var listBarang = <Map<String, dynamic>>[].obs;

  // Controller untuk Input Text di Pop-up
  final TextEditingController namaBarangController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchBarang(); // Ambil data otomatis saat controller dimuat
  }

  // --- FUNGSI FETCH DATA (REFRESH) ---
  Future<void> fetchBarang() async {
    try {
      isLoading.value = true;
      
      final response = await supabase
          .from('barang')
          .select('*')
          .order('nama_barang', ascending: true);

      // Konversi hasil ke List Map dan update RxList
      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
      listBarang.value = data;

    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal mengambil data barang: $e",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi Tambah Barang
  Future<void> addBarang() async {
    if (namaBarangController.text.isEmpty) {
      Get.snackbar("Peringatan", "Data tidak boleh kosong");
      return;
    }

    try {
      isLoading.value = true;
      await supabase.from('barang').insert({
        'nama_barang': namaBarangController.text,
      });

      namaBarangController.clear();
      Get.back();
      
      // Refresh data agar list terupdate otomatis
      fetchBarang();
      
      Get.snackbar(
        "Sukses",
        "Barang berhasil ditambahkan",
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal menambah barang: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi Edit Barang
  Future<void> updateBarang(String id) async {
    if (namaBarangController.text.isEmpty) {
      Get.snackbar("Peringatan", "Data tidak boleh kosong");
      return;
    }

    try {
      isLoading.value = true;
      await supabase
          .from('barang')
          .update({
            'nama_barang': namaBarangController.text,
          })
          .eq('id', id);

      namaBarangController.clear();
      Get.back();
      
      // Refresh data agar list terupdate otomatis
      fetchBarang();

      Get.snackbar(
        "Sukses",
        "Data barang berhasil diperbarui",
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal memperbarui barang: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi Hapus Barang
  Future<void> deleteBarang(String id) async {
    try {
      await supabase.from('barang').delete().eq('id', id);
      
      // Update list lokal secara langsung agar UI responsif
      listBarang.removeWhere((item) => item['id'] == id);
      
      Get.snackbar("Sukses", "Barang berhasil dihapus");
    } catch (e) {
      Get.snackbar("Gagal", "Gagal menghapus barang: $e");
    }
  }

  @override
  void onClose() {
    namaBarangController.dispose();
    super.onClose();
  }
}