class Produk {
  final int idProduk;
  final String namaBrg;
  final String? suplier;
  final double? harga;
  final DateTime? createdAt;

  Produk({
    required this.idProduk,
    required this.namaBrg,
    this.suplier,
    this.harga,
    this.createdAt,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      idProduk: json['id_produk'],
      namaBrg: json['nama_brg'],
      suplier: json['suplier'],
      harga: json['harga'] != null ? (json['harga'] as num).toDouble() : null,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_produk': idProduk,
      'nama_brg': namaBrg,
      'suplier': suplier,
      'harga': harga,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() => "$namaBrg (${suplier ?? 'Tanpa Suplier'})";
}
