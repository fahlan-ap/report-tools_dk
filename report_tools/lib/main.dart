import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

// Import File Controller
import 'controllers/auth_controller.dart';

// Import File UI (Pastikan path dan nama class sesuai dengan file Anda)
import 'login.dart';
import 'admin_access/admin_dash.dart';
import 'user_access/user_dash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://zbpinxcbfodtmgwmhfzv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpicGlueGNiZm9kdG1nd21oZnp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzExODYyNjYsImV4cCI6MjA4Njc2MjI2Nn0.v1nOytsxVu6DrckivhQ8Rqq0NTuDz1bWF4Rpqeh_OT0',
  );

  // 2. Inisialisasi format waktu lokal Indonesia
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Inventaris App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Mendaftarkan Controller secara Global agar bisa diakses Get.find()
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
      }),
      // Jika ada session aktif, langsung ke RootPage untuk cek role, jika tidak ke Login
      initialRoute: Supabase.instance.client.auth.currentSession == null ? '/login' : '/',
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/', page: () => const RootPage()),
        GetPage(name: '/admin-dashboard', page: () => const AdminDash()),
        GetPage(name: '/user-peminjaman', page: () => const UserDash()),
      ],
    );
  }
}

/// Widget Penentu: Membaca Role dari Database dan Mengarahkan ke UI yang sesuai
class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    // Jika user tidak sengaja masuk ke sini tanpa login
    if (user == null) {
      return const LoginPage();
    }

    return FutureBuilder(
      // Mengambil data role berdasarkan ID user yang sedang login
      future: supabase.from('profiles').select().eq('id', user.id).single(),
      builder: (context, snapshot) {
        // Tampilkan loading saat proses fetch data ke Supabase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Jika terjadi error (misal data di tabel profiles tidak ada)
        if (snapshot.hasError || !snapshot.hasData) {
          return const LoginPage();
        }

        // Ambil string role dari database
        final String role = snapshot.data!['role'];

        // INTEGRASI: Mengembalikan Class UI yang sesuai dengan Role
        if (role == 'admin') {
          return const AdminDash(); // Class dari admin_dash.dart
        } else if (role == 'karyawan') {
          return const UserDash(); // Class dari user_dash.dart
        } else {
          // Jika role tidak dikenal, paksa ke login
          return const LoginPage();
        }
      },
    );
  }
}