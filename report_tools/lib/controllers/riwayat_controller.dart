import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class RiwayatController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  
  // State untuk menyimpan data yang sudah dikelompokkan
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
      
      // Ambil data 7 hari terakhir untuk audit mingguan
      final dateLimit = DateTime.now().subtract(const Duration(days: 7)).toIso8601String();

      final response = await supabase
          .from('peminjaman')
          .select('''
            *,
            profiles:id_user(nama_lengkap),
            sekolah:id_sekolah(nama_sekolah),
            detail_peminjaman(barang(nama_barang))
          ''')
          .eq('status', 'selesai')
          .gte('waktu_kembali', dateLimit)
          .order('waktu_kembali', ascending: false);

      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

      // Mengelompokkan data berdasarkan tanggal hari (Senin, Selasa, dsb)
      Map<String, List<Map<String, dynamic>>> tempGrouped = {};
      
      for (var item in data) {
        DateTime date = DateTime.parse(item['waktu_kembali']);
        // Format: "Senin, 16 Februari 2026"
        String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
        
        if (tempGrouped[formattedDate] == null) {
          tempGrouped[formattedDate] = [];
        }
        tempGrouped[formattedDate]!.add(item);
      }

      groupedRiwayat.value = tempGrouped;
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil riwayat: $e");
    } finally {
      isLoading.value = false;
    }
  }
}