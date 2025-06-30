import 'package:flutter/material.dart';
import 'package:kasirku/barangmasuk.dart';
import 'package:kasirku/barangkeluar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laporan Barang Keluar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LaporanBarangKeluarPage(),
    );
  }
}
