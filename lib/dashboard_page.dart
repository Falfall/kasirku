import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int totalBarang = 0;
  int totalTransaksi = 0;
  int pendapatanHariIni = 0;

  final List<Map<String, dynamic>> penjualanKasir = [
    {'nama': 'Ani', 'jumlah': 30, 'warna': Colors.blue},
    {'nama': 'Budi', 'jumlah': 45, 'warna': Colors.green},
    {'nama': 'Citra', 'jumlah': 25, 'warna': Colors.orange},
    {'nama': 'Dedi', 'jumlah': 38, 'warna': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  void fetchDashboardData() {
    setState(() {
      totalBarang = 128;
      totalTransaksi = 45;
      pendapatanHariIni = 325000;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Kasir'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4, // Buat kotak lebih kecil
              ),
              children: [
                _buildDashboardCard(
                  icon: Icons.inventory_2,
                  label: 'Total Barang',
                  value: '$totalBarang',
                  color: Colors.blue,
                ),
                _buildDashboardCard(
                  icon: Icons.receipt_long,
                  label: 'Total Transaksi',
                  value: '$totalTransaksi',
                  color: Colors.green,
                ),
                _buildDashboardCard(
                  icon: Icons.attach_money,
                  label: 'Pendapatan Hari Ini',
                  value: formatRupiah(pendapatanHariIni),
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Penjualan per Kasir',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 60,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, interval: 10),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          if (value.toInt() >= 0 && value.toInt() < penjualanKasir.length) {
                            return Text(
                              penjualanKasir[value.toInt()]['nama'],
                              style: const TextStyle(fontSize: 12),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: penjualanKasir.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: (data['jumlah'] as int).toDouble(),
                          color: data['warna'],
                          width: 20,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ],
                    );
                  }).toList(),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

// Fungsi format Rupiah
String formatRupiah(int number) {
  return 'Rp ${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
}
