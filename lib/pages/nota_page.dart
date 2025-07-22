import 'package:flutter/material.dart';

class NotaPage extends StatelessWidget {
  final List<Map<String, dynamic>> keranjang;
  final double total;

  const NotaPage({super.key, required this.keranjang, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nota Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'KASIRKU',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tanggal: ${DateTime.now()}',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: keranjang.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = keranjang[index];
                  final subtotal = item['harga'] * item['jumlah'];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(item['nama'])),
                      Text('${item['jumlah']} x Rp${item['harga']}'),
                      Text('Rp${subtotal.toStringAsFixed(0)}'),
                    ],
                  );
                },
              ),
            ),
            const Divider(thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Rp${total.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check),
              label: const Text('Selesai'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}
