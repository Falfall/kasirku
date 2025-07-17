import 'package:flutter/material.dart';
import 'profiluser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profil Kasir',
      debugShowCheckedModeBanner: false,
      home: ProfilePage(),
    );
  }
}
