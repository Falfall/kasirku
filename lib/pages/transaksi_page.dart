import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/produk.dart';
import '../models/transaksi.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart'; 


class TransaksiPage extends StatefulWidget {
  const TransaksiPage({Key? key}) : super(key: key);

  @override
  State<TransaksiPage> createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final SupabaseService _service = SupabaseService();
  List<Produk> _produkList = [];
  Map<int, int> _jumlahMap = {};
  List<Map<String, dynamic>> _keranjang = [];
  String _search = '';
  bool _showNota = false;
  int? _idTransaksiBaru;
  DateTime? _waktuTransaksi;

  final TextEditingController _uangController = TextEditingController();
  double _uangDibayar = 0.0;

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
        _jumlahMap[produk.id] = _jumlahMap[produk.id]! - 1;
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

  Future<void> _prosesBayar() async {
    final total = _hitungTotal();
    final uang = double.tryParse(_uangController.text) ?? 0.0;

    if (_keranjang.isEmpty) {
      _showError('Keranjang masih kosong');
      return;
    }

    if (uang < total) {
      _showError('Uang tidak mencukupi');
      return;
    }

    final transaksi = Transaksi(total: total);
    final detailList = _keranjang
        .map((item) => TransaksiDetail(
              idProduk: item['id'],
              jumlah: item['jumlah'],
              harga: item['harga'],
            ))
        .toList();

    try {
      final idTrx = await _service.simpanTransaksiDanKembalikanId(transaksi, detailList);
      setState(() {
        _idTransaksiBaru = idTrx;
        _uangDibayar = uang;
        _waktuTransaksi = DateTime.now();
        _showNota = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error: $e');
      _showError('Gagal menyimpan transaksi');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildNota() {
    if (!_showNota || _keranjang.isEmpty) return const SizedBox();

    final total = _hitungTotal();
    final kembalian = _uangDibayar - total;
    final String formattedTime = _waktuTransaksi != null
        ? DateFormat('dd/MM/yyyy HH:mm:ss').format(_waktuTransaksi!)
        : '';

    return Card(
      margin: const EdgeInsets.only(top: 20),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nota Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            if (_idTransaksiBaru != null) Text('ID Transaksi: $_idTransaksiBaru'),
            Text('Tanggal & Jam: $formattedTime'),
            const Text('Admin: Admin Kasir'),
            const SizedBox(height: 10),
            ..._keranjang.map((item) {
              final subtotal = item['harga'] * item['jumlah'];
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(item['nama'])),
                  Text('${item['jumlah']} x ${item['harga']} = Rp $subtotal'),
                ],
              );
            }).toList(),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Rp ${total.toStringAsFixed(0)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Uang Dibayar:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Rp ${_uangDibayar.toStringAsFixed(0)}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kembalian:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Rp ${kembalian.toStringAsFixed(0)}'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nota siap dicetak (fitur cetak akan ditambahkan)'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  icon: const Icon(Icons.print),
                  label: const Text('Cetak Nota'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _keranjang.clear();
                      _showNota = false;
                      _idTransaksiBaru = null;
                      _uangDibayar = 0;
                      _uangController.clear();
                      _waktuTransaksi = null;
                      for (var p in _produkList) {
                        _jumlahMap[p.id] = 0;
                      }
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Transaksi Baru'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProduk = _produkList
        .where((p) => p.nama.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi Barang')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Cari produk...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => setState(() => _search = val),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredProduk.length,
                itemBuilder: (context, index) {
                  final produk = filteredProduk[index];
                  final jumlah = _jumlahMap[produk.id] ?? 0;
                  return Card(
                    child: ListTile(
                      title: Text(produk.nama),
                      subtitle: Text('Rp ${produk.harga.toStringAsFixed(0)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => _decrement(produk),
                          ),
                          Text(jumlah.toString()),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _increment(produk),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_shopping_cart),
                            onPressed: () => _tambahKeKeranjang(produk),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Rp ${_hitungTotal().toStringAsFixed(0)}'),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _uangController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Uang Dibayar',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _prosesBayar,
                  icon: const Icon(Icons.payment),
                  label: const Text('Bayar'),
                ),
              ),
              _buildNota(),
            ],
          ),
        ),
      ),
    );
  }
}
