import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get_storage/get_storage.dart';
import 'controllers/auth_controller.dart';
import 'login.dart';
import 'admin_access/admin_dash.dart';
import 'user_access/user_dash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

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
      title: 'Report Tools',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
      }),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const RootPage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/admin-dashboard', page: () => const AdminDash()),
        GetPage(name: '/user-dashboard', page: () => const UserDash()),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.data?.session;

        if (session == null) {
          return const LoginPage();
        }

        return FutureBuilder(
          future: supabase.from('profiles').select().eq('id', session.user.id).single(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (profileSnapshot.hasError || !profileSnapshot.hasData) {
              return const LoginPage();
            }

            final String role = profileSnapshot.data!['role'];

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