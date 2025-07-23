import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Menu Transaksi'),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed('/transaksiPage');
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Barang Masuk'),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed('/barangMasuk');
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt),
            title: const Text('Laporan Transaksi'),
            onTap: () {
              Navigator.pop(context); // tutup drawer
              Get.toNamed('/laporanTransaksi');
            },
          ),
          ListTile(
            leading: const Icon(Icons.insert_chart_outlined),
            title: const Text('Laporan Barang'),
            onTap: () {
              Navigator.pop(context);
              Get.toNamed('/laporanBarang');
            },
          ),
        ],
      ),
    );
  }
}
