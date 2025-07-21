// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/constants.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'dashboard.dart';
import 'profiluser.dart';
import 'daftar_barang.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ipegncurfryakwznqjci.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlwZWduY3VyZnJ5YWt3em5xamNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1NTAwODQsImV4cCI6MjA2ODEyNjA4NH0.C9fl_LPRjJkYwB3zrVZQx6l00TqQwrH7FnQDGaRjdcw',
  );

  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id', null); // inisialisasi data lokal
  // Inisialisasi GetStorage
  await GetStorage.init();

  // Inisialisasi Supabase
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const MyApp());
}

// Helper global untuk akses mudah ke client Supabase
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kasirku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => DashboardScreen(),
        '/profiluser': (context) => ProfilUserScreen(),
        '/daftar_barang': (context) => DaftarBarangPage(),
      },
    );
  }
}
