import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/produk.dart';
import '../models/transaksi.dart';
import '../widgets/00app_drawer.dart';

class TransaksiPage extends StatefulWidget {
  const TransaksiPage({Key? key}) : super(key: key);

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final SupabaseService _service = SupabaseService();
  List<Produk> _produkList = [];
  Map<int, int> _jumlahMap = {}; // id_produk => jumlah
  List<Map<String, dynamic>> _keranjang = [];
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadProduk();
  }

  Future<void> _loadProduk() async {
    final data = await _service.fetchProduk();
    setState(() {
      _produkList = data;
      for (var p in data) {
        _jumlahMap[p.id] = 0;
      }
    });
  }

  void _increment(Produk produk) {
    setState(() {
      _jumlahMap[produk.id] = (_jumlahMap[produk.id] ?? 0) + 1;
    });
  }

  void _decrement(Produk produk) {
    setState(() {
      if ((_jumlahMap[produk.id] ?? 0) > 0) {
        _jumlahMap[produk.id] = (_jumlahMap[produk.id]! - 1);
      }
    });
  }

  void _tambahKeKeranjang(Produk produk) {
    final jumlah = _jumlahMap[produk.id] ?? 0;
    if (jumlah > 0) {
      final index = _keranjang.indexWhere((e) => e['id'] == produk.id);
      setState(() {
        if (index >= 0) {
          _keranjang[index]['jumlah'] += jumlah;
        } else {
          _keranjang.add({
            'id': produk.id,
            'nama': produk.nama,
            'harga': produk.harga,
            'jumlah': jumlah,
          });
        }
        _jumlahMap[produk.id] = 0;
      });
    }
  }

  double _hitungTotal() {
    return _keranjang.fold(
      0,
      (total, item) => total + item['harga'] * item['jumlah'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProduk =
        _produkList
            .where((p) => p.nama.toLowerCase().contains(_search.toLowerCase()))
            .toList();

    return Scaffold(
      // drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Transaksi Barang'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  _search = val;
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: filteredProduk.length,
                itemBuilder: (context, index) {
                  final produk = filteredProduk[index];
                  final jumlah = _jumlahMap[produk.id] ?? 0;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  produk.nama,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Harga: Rp ${produk.harga.toStringAsFixed(0)}',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _decrement(produk),
                              ),
                              Container(
                                width: 30,
                                alignment: Alignment.center,
                                child: Text(
                                  jumlah.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => _increment(produk),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => _tambahKeKeranjang(produk),
                            icon: const Icon(Icons.shopping_cart_checkout),
                            label: const Text('Tambah'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 24, thickness: 2),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '🛒 Keranjang:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 120,
              child:
                  _keranjang.isEmpty
                      ? const Center(child: Text('Keranjang kosong'))
                      : ListView.builder(
                        itemCount: _keranjang.length,
                        itemBuilder: (context, index) {
                          final item = _keranjang[index];
                          final subtotal = item['jumlah'] * item['harga'];
                          return ListTile(
                            dense: true,
                            title: Text(item['nama']),
                            subtitle: Text(
                              '${item['jumlah']} x Rp ${item['harga'].toStringAsFixed(0)} = Rp ${subtotal.toStringAsFixed(0)}',
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Rp ${_hitungTotal().toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_keranjang.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(Icons.warning, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(child: Text('Keranjang masih kosong')),
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }

                  final total = _hitungTotal();
                  final transaksi = Transaksi(total: total);
                  final detailList =
                      _keranjang.map((item) {
                        return TransaksiDetail(
                          idProduk: item['id'],
                          jumlah: item['jumlah'],
                          harga: item['harga'],
                        );
                      }).toList();

                  try {
                    await _service.insertTransaksi(transaksi, detailList);

                    setState(() {
                      _keranjang.clear();
                      for (var p in _produkList) {
                        _jumlahMap[p.id] = 0;
                      }
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('Transaksi berhasil disimpan'),
                            ),
                          ],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } catch (e) {
                    debugPrint('Gagal simpan transaksi: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menyimpan transaksi'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Bayar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
