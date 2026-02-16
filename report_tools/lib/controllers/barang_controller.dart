import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BarangController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  var isLoading = false.obs;
  
  // Controller untuk Input Text di Pop-up
  final TextEditingController namaBarangController = TextEditingController();

  Stream<List<Map<String, dynamic>>> get barangStream {
    return supabase
        .from('barang')
        .stream(primaryKey: ['id'])
        .order('nama_barang', ascending: true);
  }

  // FUNGSI TAMBAH BARANG
  Future<void> addBarang() async {
    if (namaBarangController.text.isEmpty) {
      Get.snackbar("Peringatan", "Nama barang tidak boleh kosong");
      return;
    }

    try {
      isLoading.value = true;
      await supabase.from('barang').insert({
        'nama_barang': namaBarangController.text,
      });
      
      namaBarangController.clear(); // Bersihkan input setelah sukses
      Get.back(); // Tutup Pop-up
      Get.snackbar("Sukses", "Barang berhasil ditambahkan", 
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", "Gagal menambah barang: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // FUNGSI EDIT BARANG
  Future<void> updateBarang(String id) async {
    if (namaBarangController.text.isEmpty) {
      Get.snackbar("Peringatan", "Nama barang tidak boleh kosong");
      return;
    }

    try {
      isLoading.value = true;
      await supabase.from('barang').update({
        'nama_barang': namaBarangController.text,
      }).eq('id', id); // Filter berdasarkan ID barang yang diedit
      
      namaBarangController.clear();
      Get.back(); // Tutup dialog
      Get.snackbar("Sukses", "Data barang berhasil diperbarui", 
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", "Gagal memperbarui barang: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBarang(String id) async {
    try {
      await supabase.from('barang').delete().eq('id', id);
      Get.snackbar("Sukses", "Barang berhasil dihapus");
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus barang: $e");
    }
  }

  @override
  void onClose() {
    namaBarangController.dispose();
    super.onClose();
  }
}