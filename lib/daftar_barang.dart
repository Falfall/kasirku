import 'package:flutter/material.dart';

class DaftarBarangPage extends StatefulWidget {
  const DaftarBarangPage({super.key});

  @override
  State<DaftarBarangPage> createState() => _DaftarBarangPageState();
}

class _DaftarBarangPageState extends State<DaftarBarangPage> {
  List<ItemBarang> barangList = [
    ItemBarang(nama: 'minyak goreng', kode: 'SB001', harga: 'Rp 10.000', stok: '25 pcs'),
    ItemBarang(nama: 'Pasta Gigi', kode: 'PG002', harga: 'Rp 12.000', stok: '10 pcs'),
  ];

  final TextEditingController _searchController = TextEditingController();

  void _showForm({ItemBarang? item, int? index}) {
    final namaController = TextEditingController(text: item?.nama ?? '');
    final kodeController = TextEditingController(text: item?.kode ?? '');
    final hargaController = TextEditingController(text: item?.harga ?? '');
    final stokController = TextEditingController(text: item?.stok ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'Tambah Barang' : 'Edit Barang'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: namaController, decoration: const InputDecoration(labelText: 'Nama')),
              TextField(controller: kodeController, decoration: const InputDecoration(labelText: 'Kode')),
              TextField(controller: hargaController, decoration: const InputDecoration(labelText: 'Harga')),
              TextField(controller: stokController, decoration: const InputDecoration(labelText: 'Stok')),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Simpan'),
            onPressed: () {
              if (namaController.text.isEmpty ||
                  kodeController.text.isEmpty ||
                  hargaController.text.isEmpty ||
                  stokController.text.isEmpty) {
                return; // simple validation
              }
              setState(() {
                if (item == null) {
                  barangList.add(ItemBarang(
                    nama: namaController.text,
                    kode: kodeController.text,
                    harga: hargaController.text,
                    stok: stokController.text,
                  ));
                } else if (index != null) {
                  barangList[index] = ItemBarang(
                    nama: namaController.text,
                    kode: kodeController.text,
                    harga: hargaController.text,
                    stok: stokController.text,
                  );
                }
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _hapusBarang(int index) {
    setState(() => barangList.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = barangList.where((barang) {
      final query = _searchController.text.toLowerCase();
      return barang.nama.toLowerCase().contains(query) ||
          barang.kode.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan Logout button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Barang',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.black),
                    tooltip: 'Logout',
                    onPressed: () {
                      Navigator.pushNamed(context, '/logout');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search field
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari Barang...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              // Tombol tambah barang
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Barang'),
                  onPressed: () => _showForm(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Daftar barang
              Expanded(
                child: filteredList.isEmpty
                    ? const Center(child: Text('Tidak ada barang ditemukan.'))
                    : ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, i) {
                          final barang = filteredList[i];
                          final index = barangList.indexOf(barang);
                          return Column(
                            children: [
                              ItemCard(
                                barang: barang,
                                onEdit: () => _showForm(item: barang, index: index),
                                onDelete: () => _hapusBarang(index),
                              ),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemBarang {
  final String nama, kode, harga, stok;
  ItemBarang({required this.nama, required this.kode, required this.harga, required this.stok});
}

class ItemCard extends StatelessWidget {
  final ItemBarang barang;
  final VoidCallback onEdit, onDelete;

  const ItemCard({super.key, required this.barang, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(barang.nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Kode: ${barang.kode}'),
                Text('Harga: ${barang.harga}'),
                Text('Stok: ${barang.stok}'),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: onEdit),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
            ],
          ),
        ],
      ),
    );
  }
}
