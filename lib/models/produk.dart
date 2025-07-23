class Produk {
  final int id;
  final String nama;
  final double harga;

  Produk({required this.id, required this.nama, required this.harga});

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id_produk'],
      nama: json['nama_brg'],
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
    );
  }
}
