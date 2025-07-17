class Transaksi {
  final double total;

  Transaksi({required this.total});
}

class TransaksiDetail {
  final int idProduk;
  final int jumlah;
  final double harga;

  TransaksiDetail({
    required this.idProduk,
    required this.jumlah,
    required this.harga,
  });
}
