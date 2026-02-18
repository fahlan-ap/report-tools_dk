import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  
  // State Management UI
  var isLoading = false.obs;
  var listPeminjamanAktif = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPeminjamanAktif(); 
  }

  // --- FUNGSI UTAMA FETCH DATA ---
  Future<void> fetchPeminjamanAktif() async {
    try {
      isLoading.value = true;
      
      //Joint Data Table
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
          .eq('status', 'berlangsung')
          .order('waktu_pinjam', ascending: false);

      listPeminjamanAktif.value = List<Map<String, dynamic>>.from(response);
      
      print("Dashboard Admin: Data berhasil diperbarui otomatis.");
    } catch (e) {
      print("Error Fetch Dashboard: $e");
    } finally {
      isLoading.value = false;
    }
  }

  int get totalPinjamAktif => listPeminjamanAktif.length;

  void clearData() {
    listPeminjamanAktif.clear();
  }
}