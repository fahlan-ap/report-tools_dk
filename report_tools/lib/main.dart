import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

// Import File Controller
import 'controllers/auth_controller.dart';

// Import File UI 
import 'login.dart';
import 'admin_access/admin_dash.dart';
import 'user_access/user_dash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisiasi Supabase
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
      }),
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

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      return const LoginPage();
    }

    return FutureBuilder(
      future: supabase.from('profiles').select().eq('id', user.id).single(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const LoginPage();
        }

        final String role = snapshot.data!['role'];

        if (role == 'admin') {
          return const AdminDash();
        } else if (role == 'user') {
          return const UserDash();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}