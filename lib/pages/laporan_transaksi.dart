import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../services/supabase_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../widgets/app_drawer.dart';

class LaporanTransaksiPage extends StatefulWidget {
  const LaporanTransaksiPage({Key? key}) : super(key: key);

  @override
  State<LaporanTransaksiPage> createState() => _LaporanTransaksiPageState();
}

class _LaporanTransaksiPageState extends State<LaporanTransaksiPage> {
  final SupabaseService _service = SupabaseService();

  DateTime _selectedDate = DateTime.now();
  int _totalTransaksi = 0;
  int _produkTerjual = 0;
  double _pendapatanHariIni = 0;
  List<ChartData> _weeklyData = [];
  List<Map<String, dynamic>> _lastTransaksis = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _fetchLaporan();
  }

  Future<void> _exportToPdf() async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate);

    // Ambil semua transaksi hari ini
    final transaksiHariIni = await _service.getAllTransaksiHariIni(
      _selectedDate,
    );

    pdf.addPage(
      pw.Page(
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'LAPORAN TRANSAKSI',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Tanggal: $dateStr'),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Total Pendapatan: Rp ${_pendapatanHariIni.toStringAsFixed(0)}',
                ),
                pw.Text('Total Transaksi: $_totalTransaksi'),
                pw.Text('Produk Terjual: $_produkTerjual'),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Detail Transaksi Hari Ini:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),

                // TABEL
                if (transaksiHariIni.isEmpty)
                  pw.Text('Belum ada transaksi.')
                else
                  pw.Table(
                    border: pw.TableBorder.all(color: PdfColors.grey),
                    columnWidths: {
                      0: const pw.FixedColumnWidth(30),
                      1: const pw.FixedColumnWidth(60),
                      2: const pw.FlexColumnWidth(2),
                      3: const pw.FlexColumnWidth(2),
                    },
                    children: [
                      // Header
                      pw.TableRow(
                        decoration: const pw.BoxDecoration(
                          color: PdfColors.grey300,
                        ),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              'No',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              'ID',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              'Tanggal',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              'Total',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Baris Data
                      ...transaksiHariIni.asMap().entries.map((entry) {
                        final index = entry.key + 1;
                        final trx = entry.value;
                        final tanggal = DateFormat(
                          'dd MMM yyyy',
                          'id_ID',
                        ).format(DateTime.parse(trx['tanggal']));
                        final id = trx['id'].toString();
                        final total = 'Rp ${trx['total']}';

                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(index.toString()),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(id),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(tanggal),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(total),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
              ],
            ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _fetchLaporan() async {
    final laporan = await _service.getLaporanHarian(_selectedDate);
    final mingguan = await _service.getLaporanMingguan();
    final lastTrxList = await _service.getLastTransaksi(limit: 5);

    setState(() {
      _pendapatanHariIni = laporan['total'] ?? 0;
      _totalTransaksi = laporan['jumlah'] ?? 0;
      _produkTerjual = laporan['produk_terjual'] ?? 0;
      _weeklyData =
          mingguan
              .map(
                (e) => ChartData(
                  DateFormat('E', 'id_ID').format(DateTime.parse(e['tanggal'])),
                  (e['total'] as num).toDouble(),
                ),
              )
              .toList();
      _lastTransaksis = lastTrxList;
    });
  }

  void _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchLaporan();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Laporan Transaksi'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tanggal: $dateStr',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    onPressed: _pilihTanggal,
                    icon: const Icon(Icons.date_range),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.blue[50],
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan $dateStr',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Total Pendapatan',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Text(
                      'Rp ${_pendapatanHariIni.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Total Transaksi: $_totalTransaksi'),
                    Text('Produk Terjual: $_produkTerjual'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Grafik Penjualan Minggu Ini',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries>[
                  ColumnSeries<ChartData, String>(
                    dataSource: _weeklyData,
                    xValueMapper: (ChartData data, _) => data.hari,
                    yValueMapper: (ChartData data, _) => data.total,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    color: Colors.indigo,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Transaksi Terakhir',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _lastTransaksis.isNotEmpty
                ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ), // MARGIN KIRI KANAN
                  child: Column(
                    children:
                        _lastTransaksis.map((trx) {
                          final tanggal = DateFormat(
                            'dd MMMM yyyy',
                            'id_ID',
                          ).format(DateTime.parse(trx['tanggal']));
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.receipt_long,
                                        color: Colors.indigo,
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '#${trx['id']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(tanggal),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Rp ${trx['total']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                )
                : const Text('Belum ada transaksi.'),
            const SizedBox(height: 28),

            Center(
              child: ElevatedButton.icon(
                onPressed: _exportToPdf,
                icon: const Icon(Icons.download),
                label: const Text('Unduh Laporan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String hari;
  final double total;

  ChartData(this.hari, this.total);
}
