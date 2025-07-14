import 'package:flutter/material.dart';
import 'package:kasirku/daftar_barang.dart';
import 'package:kasirku/profiluser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ProfilePage(), // Ubah sesuai kebutuhan
    );
  }
}
