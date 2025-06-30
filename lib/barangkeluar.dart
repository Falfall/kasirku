import 'package:flutter/material.dart';

class LaporanBarangKeluarPage extends StatefulWidget {
  const LaporanBarangKeluarPage({super.key});

  @override
  State<LaporanBarangKeluarPage> createState() => _LaporanBarangKeluarPageState();
}

class _LaporanBarangKeluarPageState extends State<LaporanBarangKeluarPage> {
  DateTime? _selectedDate;

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.month}/${date.day}/${date.year}";
  }

  final List<Map<String, dynamic>> dataBarangKeluar = [
    {
      'tanggal': '7/2/2025',
      'nama': 'Bola plastik',
      'kode': 'BP001',
      'jumlah': -2,
    },
    {
      'tanggal': '7/2/2025',
      'nama': 'Sepatu kulit',
      'kode': 'SID01',
      'jumlah': -3,
    },
    {
      'tanggal': '8/2/2025',
      'nama': 'Kain Pel',
      'kode': 'K001',
      'jumlah': -5,
    },
    {
      'tanggal': '8/2/2025',
      'nama': 'Lilin',
      'kode': 'L002',
      'jumlah': -1,
    },
    {
      'tanggal': '8/2/2025',
      'nama': 'Lem tembak',
      'kode': 'LT001',
      'jumlah': -4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Barang Keluar"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _pickDate(context),
              child: AbsorbPointer(
                child: TextField(
                  controller: TextEditingController(text: _formatDate(_selectedDate)),
                  decoration: InputDecoration(
                    hintText: "Pilih Tanggal",
                    prefixIcon: const Icon(Icons.date_range),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              decoration: InputDecoration(
                hintText: "Search product",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: const [
                Expanded(flex: 2, child: Text("Tanggal Keluar", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 3, child: Text("Nama Barang", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text("Kode", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text("Jumlah", style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),

            const Divider(),

            Expanded(
              child: ListView.builder(
                itemCount: dataBarangKeluar.length,
                itemBuilder: (context, index) {
                  final item = dataBarangKeluar[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text(item['tanggal'])),
                        Expanded(flex: 3, child: Text(item['nama'])),
                        Expanded(flex: 2, child: Text(item['kode'])),
                        Expanded(
                          flex: 1,
                          child: Text(
                            item['jumlah'].toString(),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade200,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Ekspor PDF"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
