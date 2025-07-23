import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DaftarBarangPage extends StatefulWidget {
  const DaftarBarangPage({super.key});

  @override
  State<DaftarBarangPage> createState() => _DaftarBarangPageState();
}

class _DaftarBarangPageState extends State<DaftarBarangPage> {
  final namaController = TextEditingController();
  final supplierController = TextEditingController();
  final hargaController = TextEditingController();

  List<dynamic> daftarBarang = [];

  @override
  void initState() {
    super.initState();
    getBarang();
  }

  Future<void> getBarang() async {
    final response = await Supabase.instance.client
        .from('produk')
        .select()
        .order('id_produk', ascending: true);

    setState(() {
      daftarBarang = response;
    });
  }

  Future<void> simpanBarang() async {
    final nama = namaController.text.trim();
    final supplier = supplierController.text.trim();
    final harga = hargaController.text.trim();

    if (nama.isEmpty || supplier.isEmpty || harga.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field harus diisi')),
      );
      return;
    }

    try {
      await Supabase.instance.client.from('produk').insert({
        'nama_brg': nama,
        'suplier': supplier, // pastikan kolom di Supabase 'suplier' (tanpa "p" kedua)
        'harga': int.parse(harga),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barang berhasil disimpan')),
      );

      // Kosongkan field dan refresh data
      namaController.clear();
      supplierController.clear();
      hargaController.clear();
      getBarang();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
  }

  void showTambahDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tambah Barang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: 'Nama Barang'),
            ),
            TextField(
              controller: supplierController,
              decoration: const InputDecoration(labelText: 'Supplier'),
            ),
            TextField(
              controller: hargaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Harga'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              simpanBarang();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Barang'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: showTambahDialog,
          ),
        ],
      ),
      body: daftarBarang.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: daftarBarang.length,
              itemBuilder: (context, index) {
                final barang = daftarBarang[index];
                return ListTile(
                  title: Text(barang['nama_brg'] ?? ''),
                  subtitle: Text(
                      'Suplier: ${barang['suplier']} | Harga: ${barang['harga']}'),
                );
              },
            ),
    );
  }
}
