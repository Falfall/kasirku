import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MaterialApp(
    home: Dashboard(),
    debugShowCheckedModeBanner: false,
    title: 'Aplikasi Kasir',
  ));
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  final List<double> penjualanMingguan = [3, 5, 4, 7, 6, 8, 10];

  final List<Map<String, dynamic>> transaksi = [
    {"id": "#20231", "jam": "11.00", "total": 150000},
    {"id": "#20232", "jam": "12.45", "total": 170000},
    {"id": "#20233", "jam": "13.00", "total": 190000},
    {"id": "#20234", "jam": "13.45", "total": 210000},
    {"id": "#20235", "jam": "14.00", "total": 200000},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Navigasi ke halaman: ${['Transaksi', 'Struk', 'Barang'][index]}"))
    );
  }

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final last = transaksi.isNotEmpty ? transaksi.last : null;

    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        title: const Text("Dashboard"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: _navigateToProfile,
            ),
          )
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: const [
                Expanded(child: DashboardCard(title: 'Pendapatan Hari ini', value: 'Rp 0')),
                Expanded(child: DashboardCard(title: 'Total Transaksi', value: 'Rp 0')),
                Expanded(child: DashboardCard(title: 'Produk Terjual', value: '0')),
              ],
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Penjualan Minggu ini", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(7, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: penjualanMingguan[index],
                          color: Colors.blue,
                          width: 16,
                          borderRadius: BorderRadius.circular(6),
                        )
                      ],
                    );
                  }),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(hari[value.toInt()], style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
            const SizedBox(height: 16),
            last != null
                ? Text(
                    "Transaksi terakhir\n${last['id']} - ${last['jam']} - Rp.${last['total'].toStringAsFixed(0)},-",
                    textAlign: TextAlign.center,
                  )
                : const Text("Belum ada transaksi"),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.blue.shade800,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Transaksi"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: "Struk"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Barang"),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;

  const DashboardCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Kasir"),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text("Ini halaman profil kasir"),
      ),
    );
  }
}