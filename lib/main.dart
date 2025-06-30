import 'package:flutter/material.dart';
import 'package:kasirku/daftar_barang.dart';
import 'package:kasirku/logout.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kasirku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const DaftarBarangPage(),
        '/logout': (context) => const LogoutPage(), 
      },
    );
  }
}
