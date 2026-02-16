import 'dart:io';
import 'package:flutter/foundation.dart'; // PENTING: Untuk 'kIsWeb'
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart'; // PENTING: Untuk 'XFile'

class UserService {
  final supabase = Supabase.instance.client;

  // --- AMBIL DATA USER SAAT INI ---
  User? get currentUser => supabase.auth.currentUser;

  // --- AMBIL PROFIL USER (NAMA & NIP) ---
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final response =
          await supabase.from('profiles').select().eq('id', user.id).single();
      return response;
    } catch (e) {
      return null;
    }
  }

  // --- AMBIL DAFTAR BARANG ---
  Future<List<Map<String, dynamic>>> getBarangList() async {
    final response = await supabase
        .from('barang')
        .select('id, nama_barang')
        .order('nama_barang', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // --- AMBIL DAFTAR SEKOLAH ---
  Future<List<Map<String, dynamic>>> getSekolahList() async {
    final response = await supabase
        .from('sekolah')
        .select('id, nama_sekolah')
        .order('nama_sekolah', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // --- SUBMIT PEMINJAMAN BARU (SUPPORT WEB & MOBILE) ---
  Future<void> submitPeminjaman({
    required String sekolahId,
    required List<String> barangIds,
    required XFile fotoBukti, // Menggunakan XFile
  }) async {
    final user = currentUser;
    if (user == null) throw Exception("User belum login");

    final fileName =
        'pinjam_${DateTime.now().millisecondsSinceEpoch}_${user.id}.jpg';

    // LOGIKA UPLOAD HYBRID
    if (kIsWeb) {
      // JIKA WEB: Upload Binary (Bytes)
      final bytes = await fotoBukti.readAsBytes();
      await supabase.storage
          .from('bukti_peminjaman')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
    } else {
      // JIKA MOBILE: Upload File Path
      await supabase.storage
          .from('bukti_peminjaman')
          .upload(fileName, File(fotoBukti.path));
    }

    // Ambil URL Publik
    final fotoUrl = supabase.storage
        .from('bukti_peminjaman')
        .getPublicUrl(fileName);

    // Insert ke Tabel Peminjaman
    final responsePeminjaman =
        await supabase
            .from('peminjaman')
            .insert({
              'id_user': user.id,
              'id_sekolah': sekolahId,
              'waktu_pinjam': DateTime.now().toIso8601String(),
              'foto_pinjam': fotoUrl,
              'status': 'berlangsung',
            })
            .select()
            .single();

    final peminjamanId = responsePeminjaman['id'];

    // Insert ke Tabel Detail Peminjaman (Batch Insert)
    final List<Map<String, dynamic>> detailData =
        barangIds.map((barangId) {
          return {'id_peminjaman': peminjamanId, 'id_barang': barangId};
        }).toList();

    await supabase.from('detail_peminjaman').insert(detailData);
  }

  Future<void> submitPengembalian({
    required String peminjamanId, // ID transaksi yang mau diselesaikan
    required XFile fotoBuktiKembali,
  }) async {
    final user = currentUser;
    if (user == null) throw Exception("User belum login");

    // 1. Upload Foto Kondisi Kembali
    // Kita pakai timestamp agar nama file unik
    final fileName =
        'kembali_${DateTime.now().millisecondsSinceEpoch}_${user.id}.jpg';

    if (kIsWeb) {
      final bytes = await fotoBuktiKembali.readAsBytes();
      await supabase.storage
          .from('bukti_peminjaman')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
    } else {
      await supabase.storage
          .from('bukti_peminjaman')
          .upload(fileName, File(fotoBuktiKembali.path));
    }

    final fotoUrl = supabase.storage
        .from('bukti_peminjaman')
        .getPublicUrl(fileName);

    // 2. Update Data di Database
    // Mengubah status jadi 'Selesai' dan isi waktu_kembali
    await supabase
        .from('peminjaman')
        .update({
          'status': 'Selesai',
          'waktu_kembali':
              DateTime.now().toIso8601String(), // Waktu Real saat dikembalikan
          'foto_kembali': fotoUrl,
        })
        .eq('id', peminjamanId); // Update HANYA yang ID-nya cocok
  }

  // --- AMBIL DATA DASHBOARD (History Peminjaman) ---
  Future<List<Map<String, dynamic>>> fetchDashboardData() async {
    final user = currentUser;
    if (user == null) return [];

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
  }

  // --- GANTI PASSWORD ---
  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }
}
