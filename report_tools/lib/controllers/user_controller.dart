import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class UserController extends GetxController {
  final supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  // --- STATE MANAGEMENT ---
  var isLoading = false.obs;
  var listPeminjamanAktif = <Map<String, dynamic>>[].obs;
  var userProfile = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserDashboard();
    fetchUserProfile();
  }

  // --- AUTH HELPER ---
  User? get currentUser => supabase.auth.currentUser;

  // --- MASTER DATA ---
  Future<List<Map<String, dynamic>>> getBarangList() async {
    final response = await supabase
        .from('barang')
        .select('id, nama_barang')
        .order('nama_barang', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getSekolahList() async {
    final response = await supabase
        .from('sekolah')
        .select('id, nama_sekolah')
        .order('nama_sekolah', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // --- IMAGE PICKER ---
  Future<XFile?> pickImage(BuildContext context) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Pilih Sumber Foto Bukti",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.deepPurple),
              title: const Text("Kamera (Ambil Foto)"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text("Galeri (Pilih Foto)"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      try {
        return await _picker.pickImage(source: source, imageQuality: 70);
      } catch (e) {
        Get.snackbar("Error", "Gagal membuka media: $e");
        return null;
      }
    }
    return null;
  }

  // --- FUNGSI FETCH DASHBOARD USER ---
  Future<void> fetchUserDashboard() async {
    final user = currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;
      final response = await supabase
          .from('peminjaman')
          .select('''
            *,
            profiles (nama_lengkap),
            sekolah (nama_sekolah),
            detail_peminjaman (
              barang (nama_barang)
            )
          ''')
          .eq('id_user', user.id)
          .eq('status', 'berlangsung')
          .order('waktu_pinjam', ascending: false);
      
      listPeminjamanAktif.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error dashboard: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- SUBMIT PEMINJAMAN ---
  Future<void> submitPeminjaman({
    required String sekolahId,
    required List<String> barangIds,
    required XFile fotoBukti,
  }) async {
    final user = currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;
      final fileName = 'pinjam_${DateTime.now().millisecondsSinceEpoch}_${user.id}.jpg';

      if (kIsWeb) {
        final bytes = await fotoBukti.readAsBytes();
        await supabase.storage.from('bukti_peminjaman').uploadBinary(
          fileName, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));
      } else {
        await supabase.storage.from('bukti_peminjaman').upload(fileName, File(fotoBukti.path));
      }
      final fotoUrl = supabase.storage.from('bukti_peminjaman').getPublicUrl(fileName);

      final responsePeminjaman = await supabase.from('peminjaman').insert({
        'id_user': user.id,
        'id_sekolah': sekolahId,
        'waktu_pinjam': DateTime.now().toIso8601String(),
        'foto_pinjam': fotoUrl,
        'status': 'berlangsung',
      }).select().single();

      final peminjamanId = responsePeminjaman['id'];
      final List<Map<String, dynamic>> detailData = barangIds.map((barangId) {
        return {'id_peminjaman': peminjamanId, 'id_barang': barangId};
      }).toList();

      await supabase.from('detail_peminjaman').insert(detailData);
      
      await fetchUserDashboard();
      Get.snackbar("Sukses", "Peminjaman berhasil diajukan");
      
    } catch (e) {
      Get.snackbar("Error", "Gagal: $e");
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // --- SUBMIT PENGEMBALIAN ---
  Future<void> submitPengembalian({
    required Map<String, dynamic> loanData,
    required XFile fotoBuktiKembali,
  }) async {
    final user = currentUser;
    if (user == null) return;

    try {
      isLoading.value = true;
      final fileName = 'kembali_${DateTime.now().millisecondsSinceEpoch}_${user.id}.jpg';
      
      if (kIsWeb) {
        final bytes = await fotoBuktiKembali.readAsBytes();
        await supabase.storage.from('bukti_peminjaman').uploadBinary(
          fileName, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));
      } else {
        await supabase.storage.from('bukti_peminjaman').upload(fileName, File(fotoBuktiKembali.path));
      }
      final fotoUrlKembali = supabase.storage.from('bukti_peminjaman').getPublicUrl(fileName);

      final List details = loanData['detail_peminjaman'] ?? [];
      final String daftarBarang = details.map((d) => d['barang']?['nama_barang'] ?? 'Item Dihapus').join(", ");

      await supabase.from('riwayat').insert({
        'id_peminjaman': loanData['id'],
        'nama_user': loanData['profiles']?['nama_lengkap'] ?? 'Tanpa Nama',
        'nama_barang': daftarBarang,
        'nama_sekolah': loanData['sekolah']?['nama_sekolah'] ?? 'Sekolah Dihapus',
        'waktu_pinjam': loanData['waktu_pinjam'],
        'waktu_kembali': DateTime.now().toIso8601String(),
        'foto_pinjam': loanData['foto_pinjam'],
        'foto_kembali': fotoUrlKembali,
      });

      await supabase.from('detail_peminjaman').delete().eq('id_peminjaman', loanData['id']);
      await supabase.from('peminjaman').delete().eq('id', loanData['id']);

      await fetchUserDashboard();
      Get.snackbar("Sukses", "Barang telah dikembalikan");

    } catch (e) {
      Get.snackbar("Error", "Gagal memproses pengembalian");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserProfile() async {
    final user = currentUser;
    if (user == null) return;
    try {
      final res = await supabase.from('profiles').select().eq('id', user.id).single();
      userProfile.value = res;
    } catch (e) {
      debugPrint("Error profile: $e");
    }
  }
}