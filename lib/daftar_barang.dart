import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DaftarBarangPage extends StatefulWidget {
  const DaftarBarangPage({Key? key}) : super(key: key);

  @override
  State<DaftarBarangPage> createState() => _DaftarBarangPageState();
}

class _DaftarBarangPageState extends State<DaftarBarangPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _barangList = [];

  final TextEditingController kodeController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController stokController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchBarang();
  }

  Future<void> fetchBarang() async {
    try {
      final response =
          await supabase
              .from('daftar_barang')
              .select(); // Hapus order by jika kolom waktu tidak tersedia

      print("DATA DARI SUPABASE: $response");

      setState(() {
        _barangList = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print("GAGAL AMBIL DATA: $e");
    }
  }

  Future<void> tambahBarang() async {
    final kode = kodeController.text.trim();
    final nama = namaController.text.trim();
    final harga = int.tryParse(hargaController.text.trim()) ?? 0;
    final stok = int.tryParse(stokController.text.trim()) ?? 0;

    if (kode.isEmpty || nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kode dan nama barang wajib diisi")),
      );
      return;
    }

    try {
      await supabase.from('daftar_barang').insert({
        'kode_brg': kode,
        'nama_barang': nama,
        'harga': harga,
        'stok': stok,
      });

      kodeController.clear();
      namaController.clear();
      hargaController.clear();
      stokController.clear();

      fetchBarang();
    } catch (e) {
      print("GAGAL TAMBAH DATA: $e");
    }
  }

  void showFormDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Tambah Barang"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: kodeController,
                    decoration: const InputDecoration(labelText: 'Kode Barang'),
                  ),
                  TextField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: 'Nama Barang'),
                  ),
                  TextField(
                    controller: hargaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Harga'),
                  ),
                  TextField(
                    controller: stokController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stok'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () {
                  tambahBarang();
                  Navigator.pop(context);
                },
                child: const Text("Simpan"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Barang")),
      body:
          _barangList.isEmpty
              ? const Center(child: Text("Belum ada data barang."))
              : ListView.builder(
                itemCount: _barangList.length,
                itemBuilder: (context, index) {
                  final barang = _barangList[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text("${index + 1}")),
                    title: Text(barang['nama_barang'] ?? 'Tanpa Nama'),
                    subtitle: Text(
                      'Kode: ${barang['kode_brg'] ?? '-'} | Harga: ${barang['harga'] ?? 0} | Stok: ${barang['stok'] ?? 0}',
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: showFormDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
