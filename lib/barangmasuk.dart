import 'package:flutter/material.dart';

class LaporanBarangMasukPage extends StatefulWidget {
  const LaporanBarangMasukPage({super.key});

  @override
  State<LaporanBarangMasukPage> createState() => _LaporanBarangMasukPageState();
}

class _LaporanBarangMasukPageState extends State<LaporanBarangMasukPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return "${date.month}/${date.day}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Barang Masuk"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Tanggal Mulai",
                          prefixIcon: const Icon(Icons.date_range),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          labelText: _startDate == null ? null : _formatDate(_startDate),
                        ),
                        controller: TextEditingController(text: _formatDate(_startDate)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Tanggal Akhir",
                          prefixIcon: const Icon(Icons.date_range),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          labelText: _endDate == null ? null : _formatDate(_endDate),
                        ),
                        controller: TextEditingController(text: _formatDate(_endDate)),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            TextField(
              decoration: InputDecoration(
                hintText: "Nama Barang",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: const [
                Expanded(flex: 3, child: Text("Nama Barang", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 2, child: Text("Kode Barang", style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text("Jumlah", style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),

            const Divider(),

            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Row(
                    children: const [
                      Expanded(flex: 3, child: Text("Barang A")),
                      Expanded(flex: 2, child: Text("BRG001")),
                      Expanded(flex: 1, child: Text("10")),
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade200,
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
