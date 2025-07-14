import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:kasirku/login_screen.dart';
import 'package:kasirku/register_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String registrasi = '/registrasi';

  static final routes = [
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: registrasi, page: () => RegisterScreen()),
  ];
}
