import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

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
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan tidak terduga',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    Get.offAllNamed('/login');
  }
}