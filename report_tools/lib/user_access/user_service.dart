import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class UserService {
  final supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  // --- AUTH HELPER ---
  User? get currentUser => supabase.auth.currentUser;

  // --- IMAGE PICKER (Alur Kamera/Galeri) ---
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
              "Pilih Sumber Foto",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.deepPurple),
              title: const Text("Kamera"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text("Galeri"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      try {
        return await _picker.pickImage(source: source);
      } catch (e) {
        debugPrint("Error picking image: $e");
        return null;
      }
    }
    return null;
  }

  // --- AMBIL PROFIL USER ---
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;
    try {
      return await supabase.from('profiles').select().eq('id', user.id).single();
    } catch (e) {
      return null;
    }
  }

  // --- MASTER DATA (BARANG & SEKOLAH) ---
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

  // --- SUBMIT PEMINJAMAN ---
  Future<void> submitPeminjaman({
    required String sekolahId,
    required List<String> barangIds,
    required XFile fotoBukti,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception("User belum login");

    final fileName = 'pinjam_${DateTime.now().millisecondsSinceEpoch}_${user.id}.jpg';

    if (kIsWeb) {
      final bytes = await fotoBukti.readAsBytes();
      await supabase.storage.from('bukti_peminjaman').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
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
  }

  // --- FETCH DASHBOARD DATA ---
  Future<List<Map<String, dynamic>>> fetchDashboardData() async {
    final user = currentUser;
    if (user == null) return [];

    try {
      final response = await supabase
          .from('peminjaman')
          .select('''
            *,
            sekolah (nama_sekolah),
            detail_peminjaman (
              barang (nama_barang)
            )
          ''')
          .eq('id_user', user.id)
          .order('waktu_pinjam', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error dashboard: $e");
      return [];
    }
  }

  // --- LOGIKA PENGEMBALIAN: SALIN DATA KE RIWAYAT -> HAPUS DARI PEMINJAMAN ---
  Future<void> submitPengembalian({
    required Map<String, dynamic> loanData,
    required XFile fotoBuktiKembali,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception("User tidak terdeteksi");

    final fileName = 'kembali_${DateTime.now().millisecondsSinceEpoch}_${user.id}.jpg';
    
    // 1. Upload Foto Pengembalian ke Storage
    if (kIsWeb) {
      final bytes = await fotoBuktiKembali.readAsBytes();
      await supabase.storage.from('bukti_peminjaman').uploadBinary(
        fileName, bytes, fileOptions: const FileOptions(contentType: 'image/jpeg'));
    } else {
      await supabase.storage.from('bukti_peminjaman').upload(fileName, File(fotoBuktiKembali.path));
    }
    final fotoUrlKembali = supabase.storage.from('bukti_peminjaman').getPublicUrl(fileName);

    // 2. Persiapkan Data Snapshot untuk Riwayat
    final List details = loanData['detail_peminjaman'] ?? [];
    final String daftarBarang = details.map((d) => d['barang']?['nama_barang'] ?? 'Item Dihapus').join(", ");
    final profil = await getUserProfile();

    try {
      // 3. Masukkan ke tabel 'riwayat' (Snapshot Data & Foto)
      await supabase.from('riwayat').insert({
        'id_peminjaman': loanData['id'],
        'nama_karyawan': profil?['nama_lengkap'] ?? 'Tanpa Nama',
        'nama_barang': daftarBarang,
        'nama_sekolah': loanData['sekolah']?['nama_sekolah'] ?? 'Sekolah Dihapus',
        'waktu_pinjam': loanData['waktu_pinjam'],
        'waktu_kembali': DateTime.now().toIso8601String(),
        'foto_pinjam': loanData['foto_pinjam'], // Salin URL foto pinjam dari peminjaman
        'foto_kembali': fotoUrlKembali,          // URL foto pengembalian baru
      });

      // 4. Hapus dari tabel 'detail_peminjaman' & 'peminjaman'
      // Menghapus detail terlebih dahulu untuk menghindari constraint error
      await supabase.from('detail_peminjaman').delete().eq('id_peminjaman', loanData['id']);
      await supabase.from('peminjaman').delete().eq('id', loanData['id']);

    } catch (e) {
      debugPrint("Gagal pindah data ke riwayat: $e");
      throw Exception("Proses pengembalian gagal, silakan coba lagi.");
    }
  }
}