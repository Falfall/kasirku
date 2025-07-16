import 'package:flutter/material.dart';
import 'daftar_barang.dart';
import 'logout.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KasirKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Halaman pertama saat aplikasi dijalankan
      home: const DaftarBarangPage(),
      
      // Daftar semua routes yang bisa diakses
      routes: {
        '/logout': (context) => const LogoutPage(),
      },
    );
  }
}
