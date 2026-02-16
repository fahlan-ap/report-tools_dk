import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  // Stream untuk mengambil data peminjaman beserta relasinya
  Stream<List<Map<String, dynamic>>> get activePeminjamanStream {
    return supabase
        .from('peminjaman')
        .stream(primaryKey: ['id'])
        .eq('status', 'berlangsung')
        .order('waktu_pinjam', ascending: false)
        .map((maps) => maps);
  }

  // Fungsi untuk mengambil data detail relasi secara manual (karena stream join di Supabase terbatas)
  // Kita akan menggunakan select dengan query string untuk mendapatkan data relasi
  Future<List<Map<String, dynamic>>> getDetailedPeminjaman() async {
    try {
      final data = await supabase
          .from('peminjaman')
          .select('''
            *,
            profiles:id_karyawan(nama),
            barang:id_barang(nama_barang),
            sekolah:id_sekolah(nama_sekolah)
          ''')
          .eq('status', 'berlangsung')
          .order('waktu_pinjam', ascending: false);
      
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print("Error Join Table: $e");
      return [];
    }
  }
}