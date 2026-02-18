import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get_storage/get_storage.dart';

// Import File Controller
import 'controllers/auth_controller.dart';

// Import File UI 
import 'login.dart';
import 'admin_access/admin_dash.dart';
import 'user_access/user_dash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi GetStorage untuk menyimpan cache role
  await GetStorage.init();

  // 2. Inisiasi Supabase
  await Supabase.initialize(
    url: 'https://zbpinxcbfodtmgwmhfzv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpicGlueGNiZm9kdG1nd21oZnp2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzExODYyNjYsImV4cCI6MjA4Njc2MjI2Nn0.v1nOytsxVu6DrckivhQ8Rqq0NTuDz1bWF4Rpqeh_OT0',
  );

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Inisialisasi AuthController secara permanen
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
      }),
      // Selalu mulai dari RootPage untuk pengecekan sesi yang stabil
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const RootPage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/admin-dashboard', page: () => const AdminDash()),
        GetPage(name: '/user-peminjaman', page: () => const UserDash()),
      ],
    );
  }
}

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Tampilkan loading saat Supabase sedang mencoba mengambil session lama
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.data?.session;

        // Jika tidak ada session, langsung ke Login
        if (session == null) {
          return const LoginPage();
        }

        // Jika ada session, cek Role (Gunakan FutureBuilder untuk ambil data profiles)
        return FutureBuilder(
          future: supabase.from('profiles').select().eq('id', session.user.id).single(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (profileSnapshot.hasError || !profileSnapshot.hasData) {
              return const LoginPage(); // Gagal ambil profil, paksa login ulang
            }

            final String role = profileSnapshot.data!['role'];

            // Arahkan sesuai role
            if (role == 'admin') {
              return const AdminDash();
            } else {
              return const UserDash();
            }
          },
        );
      },
    );
  }
}