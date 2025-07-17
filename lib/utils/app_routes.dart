// lib/utils/app_routes.dart

import 'package:get/get.dart';
import '../../pages/barang_masuk_page.dart';
import '../../pages/transaksi_page.dart';
import '../../pages/laporan_barang_page.dart';
import '../../pages/laporan_transaksi.dart';

class AppRoutes {
  static const String barangMasuk = '/barang-masuk';
  static const String laporanTransaksi = '/laporan-transaksi';
  static const String laporanBarang = '/laporan-barang';
  static const String transaksiPage = '/transaksi';

  static final routes = [
    GetPage(name: barangMasuk, page: () => const BarangMasukPage()),
    GetPage(name: laporanTransaksi, page: () => const LaporanTransaksiPage()),
    GetPage(name: laporanBarang, page: () => const LaporanBarangPage()),
    GetPage(name: transaksiPage, page: () => const TransaksiPage()),
  ];
}
