import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../services/supabase_service.dart';
import '../widgets/00app_drawer.dart';

class LaporanBarangPage extends StatefulWidget {
  const LaporanBarangPage({super.key});

  @override
  State<LaporanBarangPage> createState() => _LaporanBarangPageState();
}

class _LaporanBarangPageState extends State<LaporanBarangPage> {
  final _searchController = TextEditingController();
  DateTimeRange? _tanggalRange;
  List<Map<String, dynamic>> _laporanGabungan = [];
  bool _isLoading = false;
  String _jenisFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    setState(() => _isLoading = true);

    final start =
        _tanggalRange?.start ??
        DateTime.now().subtract(const Duration(days: 30));
    final end = _tanggalRange?.end ?? DateTime.now();
    final keyword = _searchController.text.trim();

    final hasil = await SupabaseService().getLaporanGabungan(
      start: start,
      end: end,
      keyword: keyword,
      jenisFilter: _jenisFilter,
    );

    setState(() {
      _laporanGabungan = hasil;
      _isLoading = false;
    });
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
      initialDateRange: _tanggalRange,
    );
    if (picked != null) {
      setState(() => _tanggalRange = picked);
      _fetchLaporan();
    }
  }

  void _resetFilter() {
    setState(() {
      _searchController.clear();
      _tanggalRange = null;
      _jenisFilter = 'Semua';
    });
    _fetchLaporan();
  }

  Future<void> _exportPdf() async {
    final pdf = pw.Document();
    final df = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              pw.Center(
                child: pw.Text(
                  "LAPORAN BARANG",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: ['Tanggal', 'Nama Barang', 'Jenis', 'Jumlah'],
                data:
                    _laporanGabungan.map((e) {
                      return [
                        df.format(e['tanggal']),
                        e['nama_brg'],
                        e['jenis'],
                        e['jenis'] == 'Masuk'
                            ? '+${e['jumlah']}'
                            : '-${e['jumlah']}',
                      ];
                    }).toList(),
              ),
            ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final tglText =
        _tanggalRange == null
            ? 'Pilih tanggal'
            : "${DateFormat('dd/MM/yyyy').format(_tanggalRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_tanggalRange!.end)}";

    return Scaffold(
      // drawer: const AppDrawer(),
      appBar: AppBar(title: const Text("Laporan Barang"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  flex: 7,
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari nama barang',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onSubmitted: (_) => _fetchLaporan(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  flex: 3,
                  child: SizedBox(
                    height: 44,
                    child: DropdownButtonFormField<String>(
                      value: _jenisFilter,
                      decoration: InputDecoration(
                        labelText: 'Jenis',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                      items: const [
                        DropdownMenuItem(
                          value: 'Semua',
                          child: Text('📋 Semua'),
                        ),
                        DropdownMenuItem(
                          value: 'Masuk',
                          child: Text('⬇️ Masuk'),
                        ),
                        DropdownMenuItem(
                          value: 'Keluar',
                          child: Text('⬆️ Keluar'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _jenisFilter = value);
                          _fetchLaporan();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  flex: 7,
                  child: OutlinedButton.icon(
                    onPressed: _pilihTanggal,
                    icon: const Icon(Icons.date_range),
                    label: Text(tglText, style: const TextStyle(fontSize: 14)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: OutlinedButton.icon(
                    onPressed: _resetFilter,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Reset"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child:
                    _laporanGabungan.isEmpty
                        ? const Center(child: Text("Tidak ada data."))
                        : ListView.separated(
                          itemCount: _laporanGabungan.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final item = _laporanGabungan[index];
                            return ListTile(
                              leading: Text(
                                DateFormat(
                                  'dd/MM/yyyy',
                                ).format(item['tanggal']),
                                style: const TextStyle(fontSize: 13),
                              ),
                              title: Text(
                                item['nama_brg'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                item['jenis'],
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      item['jenis'] == 'Masuk'
                                          ? Colors.green
                                          : Colors.red,
                                ),
                              ),
                              trailing: Text(
                                item['jenis'] == 'Masuk'
                                    ? '+${item['jumlah']}'
                                    : '-${item['jumlah']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      item['jenis'] == 'Masuk'
                                          ? Colors.green
                                          : Colors.red,
                                ),
                              ),
                            );
                          },
                        ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _laporanGabungan.isEmpty ? null : _exportPdf,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Ekspor PDF"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
