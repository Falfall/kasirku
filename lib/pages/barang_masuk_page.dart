import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BarangMasukPage extends StatefulWidget {
  const BarangMasukPage({super.key});

  @override
  State<BarangMasukPage> createState() => _BarangMasukPageState();
}

class _BarangMasukPageState extends State<BarangMasukPage> {
  final supabase = Supabase.instance.client;
  final currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  List<Map<String, dynamic>> _produkList = [];
  Map<String, dynamic>? _selectedProduk;
  List<Map<String, dynamic>> _barangMasukList = [];

  final _jumlahController = TextEditingController();
  final _hargaController = TextEditingController();
  final _supplierController = TextEditingController();
  final _totalController = TextEditingController();
  DateTime? _tanggalMasuk;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProduk();
    _fetchBarangMasuk();
    _jumlahController.addListener(_updateTotal);
  }

  Future<void> _fetchProduk() async {
    final res = await supabase.from('produk').select();
    setState(() {
      _produkList = List<Map<String, dynamic>>.from(res);
    });
  }

  Future<void> _fetchBarangMasuk() async {
    final res = await supabase
        .from('barang_masuk')
        .select('id, jumlah, tanggal_masuk, produk (nama_brg, harga)')
        .order('tanggal_masuk', ascending: false);
    setState(() {
      _barangMasukList = List<Map<String, dynamic>>.from(res);
    });
  }

  void _onProdukSelected(Map<String, dynamic> produk) {
    setState(() {
      _selectedProduk = produk;
      _hargaController.text = produk['harga']?.toString() ?? '0';
      _supplierController.text = produk['suplier'] ?? '';
    });
    _updateTotal();
  }

  void _updateTotal() {
    final jumlah = int.tryParse(_jumlahController.text) ?? 0;
    final harga = int.tryParse(_hargaController.text) ?? 0;
    _totalController.text = (jumlah * harga).toString();
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _tanggalMasuk = picked);
    }
  }

  Future<void> _simpanData() async {
    if (_selectedProduk == null ||
        _jumlahController.text.isEmpty ||
        _tanggalMasuk == null) {
      _showTopSnackbar('⚠️ Lengkapi semua data', isError: true);
      return;
    }

    final jumlah = int.tryParse(_jumlahController.text.trim()) ?? 0;

    setState(() => _isLoading = true);

    try {
      await supabase.from('barang_masuk').insert({
        'id_produk': _selectedProduk!['id_produk'],
        'jumlah': jumlah,
        'tanggal_masuk': _tanggalMasuk!.toIso8601String().split('T')[0],
      });

      _showTopSnackbar('✅ Data berhasil disimpan');

      _jumlahController.clear();
      _hargaController.clear();
      _supplierController.clear();
      _totalController.clear();
      setState(() {
        _selectedProduk = null;
        _tanggalMasuk = null;
      });

      await _fetchBarangMasuk();
    } catch (e) {
      _showTopSnackbar('❌ Gagal simpan: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showTopSnackbar(String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(isError ? Icons.error : Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
        ],
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _hargaController.dispose();
    _supplierController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tglText = _tanggalMasuk == null
        ? ''
        : "${_tanggalMasuk!.day}/${_tanggalMasuk!.month}/${_tanggalMasuk!.year}";

    return Scaffold(
      appBar: AppBar(title: const Text("Barang Masuk"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField<Map<String, dynamic>>(
              decoration: InputDecoration(
                labelText: 'Cari Barang',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              value: _selectedProduk,
              items: _produkList.map((produk) {
                return DropdownMenuItem(
                  value: produk,
                  child: Text(produk['nama_brg']),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) _onProdukSelected(val);
              },
            ),
            const SizedBox(height: 16),
            _inputField('Jumlah Masuk', _jumlahController, keyboardType: TextInputType.number),
            _inputField('Harga Satuan (Rp)', _hargaController,
                keyboardType: TextInputType.number, enabled: false),
            _inputField('Suplier', _supplierController, enabled: false),
            GestureDetector(
              onTap: _pilihTanggal,
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(text: tglText),
                  decoration: InputDecoration(
                    labelText: 'Tanggal Masuk',
                    suffixIcon: const Icon(Icons.calendar_today),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _inputField('Total Nilai Barang Masuk (Rp)', _totalController, enabled: false),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _simpanData,
                icon: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _isLoading ? 'Menyimpan...' : 'Simpan',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Divider(height: 1, color: Colors.grey),
            const SizedBox(height: 20),
            const Text('📦 Riwayat Barang Masuk',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _barangMasukList.isEmpty
                ? const Text('Belum ada data.')
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _barangMasukList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _barangMasukList[index];
                      final nama = item['produk']['nama_brg'] ?? '-';
                      final jumlah = item['jumlah'] ?? 0;
                      final harga = item['produk']['harga'] ?? 0;
                      final total = jumlah * harga;
                      final tanggal = item['tanggal_masuk'] ?? '';

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(nama,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("Jumlah: $jumlah"),
                            Text("Harga: ${currencyFormatter.format(harga)}"),
                            Text("Total: ${currencyFormatter.format(total)}"),
                            Text("Tanggal: $tanggal"),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
