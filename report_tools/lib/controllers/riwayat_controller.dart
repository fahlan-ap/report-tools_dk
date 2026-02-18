import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class RiwayatController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  
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
      
      // Fetch Data Riwayat
      final response = await supabase
          .from('riwayat')
          .select('*')
          .order('waktu_kembali', ascending: false);

      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

      // Day Based Sorting
      Map<String, List<Map<String, dynamic>>> tempGrouped = {};
      
      for (var item in data) {
        if (item['waktu_kembali'] == null) continue;
        
        DateTime date = DateTime.parse(item['waktu_kembali']).toLocal();
        String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
        
        if (tempGrouped[formattedDate] == null) {
          tempGrouped[formattedDate] = [];
        }
        tempGrouped[formattedDate]!.add(item);
      }

      groupedRiwayat.value = tempGrouped;
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat riwayat: $e");
    } finally {
      isLoading.value = false;
    }
  }
}