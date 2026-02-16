import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SekolahController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  var isLoading = false.obs;

  // Controller untuk Input Text di Pop-up
  final TextEditingController namaSekolahController = TextEditingController();

  Stream<List<Map<String, dynamic>>> get sekolahStream {
    return supabase
        .from('sekolah')
        .stream(primaryKey: ['id'])
        .order('nama_sekolah', ascending: true);
  }

  //Fungsi Tambah Sekolah
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
      Get.snackbar(
        "Sukses",
        "Sekolah berhasil ditambahkan",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal menambah sekolah: $e");
    } finally {
      isLoading.value = false;
    }
  }

  //Fungsi Edit Sekolah
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
      Get.snackbar(
        "Sukses",
        "Data sekolah berhasil diperbarui",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Error", "Gagal memperbarui sekolah: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSekolah(String id) async {
    try {
      await supabase.from('sekolah').delete().eq('id', id);
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
