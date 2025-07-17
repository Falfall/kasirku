import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'profiluser.dart';
import 'register_screen.dart';
import 'dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ipegncurfryakwznqjci.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlwZWduY3VyZnJ5YWt3em5xamNpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI1NTAwODQsImV4cCI6MjA2ODEyNjA4NH0.C9fl_LPRjJkYwB3zrVZQx6l00TqQwrH7FnQDGaRjdcw',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Supabase',
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
        '/profil': (context) => const ProfilScreen(),
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}
