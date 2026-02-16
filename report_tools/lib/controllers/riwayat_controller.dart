import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class RiwayatController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  
  // State untuk menyimpan data yang sudah dikelompokkan berdasarkan tanggal
  var groupedRiwayat = <String, List<Map<String, dynamic>>>{}.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRiwayat();
  }

  Future<void> fetchRiwayat() async {
    try {
      isLoading.value = true;
      
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Ambil data dari tabel 'riwayat'
      // Kita tidak butuh join profiles/sekolah/barang karena sudah tersimpan sebagai teks
      final response = await supabase
          .from('riwayat')
          .select('*')
          // Jika ingin membatasi hanya riwayat milik user yang login, 
          // pastikan tabel riwayat memiliki kolom id_user. 
          // Jika untuk Admin/Audit (semua data), hapus filter id_user.
          .order('waktu_kembali', ascending: false);

      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

      // Mengelompokkan data berdasarkan tanggal hari (Senin, Selasa, dsb)
      Map<String, List<Map<String, dynamic>>> tempGrouped = {};
      
      for (var item in data) {
        if (item['waktu_kembali'] == null) continue;
        
        DateTime date = DateTime.parse(item['waktu_kembali']).toLocal();
        // Format: "Senin, 16 Februari 2026"
        String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
        
        if (tempGrouped[formattedDate] == null) {
          tempGrouped[formattedDate] = [];
        }
        tempGrouped[formattedDate]!.add(item);
      }

      groupedRiwayat.value = tempGrouped;
    } catch (e) {
      Get.snackbar(
        "Error", 
        "Gagal mengambil data riwayat: $e",
      );
    } finally {
      isLoading.value = false;
    }
  }
}