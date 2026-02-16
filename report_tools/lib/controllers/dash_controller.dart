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

    Future<List<Map<String, dynamic>>> getDetailedPeminjaman() async {
    try {
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
          .eq('status', 'berlangsung');
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error Debug Dashboard: $e");
      return [];
    }
  }
}