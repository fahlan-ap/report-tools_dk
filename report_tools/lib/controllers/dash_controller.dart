import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  var isLoading = false.obs;

  // Variabel RxList untuk menampung data peminjaman aktif
  var listPeminjamanAktif = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPeminjamanAktif(); // Ambil data saat dashboard dibuka
  }

  // --- FUNGSI FETCH DATA (REFRESH) ---
  Future<void> fetchPeminjamanAktif() async {
    try {
      isLoading.value = true;
      
      // Mengambil data detail dengan join tabel profiles, sekolah, dan barang
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
        } catch (e) {
      print("Error Fetch Dashboard: $e");
      Get.snackbar("Error", "Gagal memuat data dashboard");
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi tambahan jika Anda ingin menghitung total pinjaman aktif untuk ringkasan di dashboard
  int get totalPinjamAktif => listPeminjamanAktif.length;
}