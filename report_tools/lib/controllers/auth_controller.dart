import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;
  final box = GetStorage();

  var isLoading = false.obs;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        final data = await supabase
            .from('profiles')
            .select()
            .eq('id', res.user!.id)
            .single();

        String role = data['role'];

        box.write('role', role);

        if (role == 'admin') {
          Get.offAllNamed('/admin-dashboard');
        } else {
          Get.offAllNamed('/user-peminjaman');
        }
      }
    } on AuthException catch (e) {
      Get.snackbar(
        'Login Gagal',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan tidak terduga',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      box.remove('role');
      await supabase.auth.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('Error', 'Gagal logout: $e');
    } finally {
      isLoading.value = false;
    }
  }
}