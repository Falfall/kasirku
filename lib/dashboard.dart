import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profiluser.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  double _totalHariIni = 0;
  List<BarChartGroupData> _chartData = [];
  bool _isChartLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTotalHariIni();
    _loadChartData();
  }

  Future<void> _loadTotalHariIni() async {
    final now = DateTime.now();
    final tanggal = now.toIso8601String().substring(0, 10);
    try {
      final response = await Supabase.instance.client
          .from('transaksi_penjualan')
          .select('total')
          .eq('tanggal', tanggal);

      double total = 0;
      for (final item in response) {
        total += (item['total'] as num?)?.toDouble() ?? 0;
      }

      setState(() {
        _totalHariIni = total;
      });
    } catch (e) {
      print("❌ Gagal ambil total hari ini: $e");
    }
  }

  Future<void> _loadChartData() async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 6));
    final formattedStart = sevenDaysAgo.toIso8601String().substring(0, 10);

    try {
      final response = await Supabase.instance.client
          .from('transaksi_penjualan')
          .select('tanggal, total')
          .gte('tanggal', formattedStart)
          .order('tanggal');

      Map<String, double> totals = {};
      for (final item in response) {
        final tgl = item['tanggal'].substring(0, 10);
        final nilai = (item['total'] as num?)?.toDouble() ?? 0;
        totals[tgl] = (totals[tgl] ?? 0) + nilai;
      }

      setState(() {
        _chartData = List.generate(7, (i) {
          final date = sevenDaysAgo.add(Duration(days: i));
          final key = date.toIso8601String().substring(0, 10);
          final total = totals[key] ?? 0;

          return BarChartGroupData(
            x: i,
            barRods: [BarChartRodData(toY: total, color: Colors.deepPurple)],
          );
        });
        _isChartLoading = false;
      });
    } catch (e) {
      print("❌ Gagal ambil data chart: $e");
      setState(() => _isChartLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _selectedIndex == 0 ? 'Dashboard Kasir' : 'Profil Pengguna',
          ),
          backgroundColor: Colors.deepPurple,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
        body:
            _selectedIndex == 0 ? _buildDashboard() : const ProfilUserScreen(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.deepPurple,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 20),
          const Text(
            'Grafik Penjualan (7 Hari Terakhir)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _isChartLoading
              ? const Center(child: CircularProgressIndicator())
              : SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barGroups: _chartData,
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            final date = DateTime.now().subtract(
                              Duration(days: 6 - index),
                            );
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(
                                '${date.day}/${date.month}',
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                  ),
                ),
              ),
          const SizedBox(height: 30),
          const Text(
            'Menu Utama',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildMenuTile(
                icon: Icons.input,
                label: 'Barang Masuk',
                onTap: () => Navigator.pushNamed(context, '/barang-masuk'),
              ),
              _buildMenuTile(
                icon: Icons.output,
                label: 'Barang Keluar',
                onTap: () => Navigator.pushNamed(context, '/barang-keluar'),
              ),
              _buildMenuTile(
                icon: Icons.receipt_long,
                label: 'Laporan',
                onTap: () => Navigator.pushNamed(context, '/laporan'),
              ),
              _buildMenuTile(
                icon: Icons.shopping_cart,
                label: 'Transaksi',
                onTap: () => Navigator.pushNamed(context, '/transaksi'),
              ),
              _buildMenuTile(
                icon: Icons.list,
                label: 'Daftar Barang',
                onTap: () => Navigator.pushNamed(context, '/daftar_barang'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total Pendapatan Hari Ini'),
            const SizedBox(height: 10),
            Text(
              'Rp ${_totalHariIni.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.deepPurple),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
