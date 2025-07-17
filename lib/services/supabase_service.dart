import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/produk.dart';
import '../models/transaksi.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // -----------------------
  // CRUD PRODUK
  // -----------------------

  Future<List<Produk>> fetchProduk() async {
    final response = await supabase
        .from('produk')
        .select('*')
        .order('nama_brg', ascending: true);

    return (response as List).map((item) => Produk.fromJson(item)).toList();
  }

  Future<void> insertProduk({
    required int idProduk,
    required String namaBrg,
    String? suplier,
    double? harga,
  }) async {
    await supabase.from('produk').insert({
      'id_produk': idProduk,
      'nama_brg': namaBrg,
      'suplier': suplier,
      'harga': harga,
    });
  }

  Future<void> updateProduk({
    required int idProduk,
    required String namaBrg,
    String? suplier,
    double? harga,
  }) async {
    await supabase
        .from('produk')
        .update({'nama_brg': namaBrg, 'suplier': suplier, 'harga': harga})
        .eq('id_produk', idProduk);
  }

  Future<void> deleteProduk(int idProduk) async {
    await supabase.from('produk').delete().eq('id_produk', idProduk);
  }

  // -----------------------
  // INSERT BARANG MASUK
  // -----------------------
  Future<void> insertBarangMasuk({
    required int idProduk,
    required int jumlah,
    DateTime? tanggalMasuk,
  }) async {
    await supabase.from('barang_masuk').insert({
      'id_produk': idProduk,
      'jumlah': jumlah,
      'tanggal_masuk':
          (tanggalMasuk ?? DateTime.now()).toIso8601String().split('T')[0],
    });
  }

  // -----------------------
  // TRANSAKSI
  // -----------------------

  Future<void> insertTransaksi(
    Transaksi transaksi,
    List<TransaksiDetail> detailList,
  ) async {
    final trxRes =
        await supabase
            .from('transaksi')
            .insert({
              'total': transaksi.total,
              'tanggal': DateTime.now().toIso8601String().split('T')[0],
            })
            .select()
            .single();

    final idTransaksi = trxRes['id'];

    final detailData =
        detailList
            .map(
              (d) => {
                'id_transaksi': idTransaksi,
                'id_produk': d.idProduk,
                'jumlah': d.jumlah,
                'harga': d.harga,
              },
            )
            .toList();

    await supabase.from('transaksi_detail').insert(detailData);
  }

  Future<Map<String, dynamic>> getLaporanHarian(DateTime date) async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = startDate.add(const Duration(days: 1));

    final transaksi = await supabase
        .from('transaksi')
        .select('id, total, tanggal')
        .gte('tanggal', startDate.toIso8601String().split('T')[0])
        .lt('tanggal', endDate.toIso8601String().split('T')[0]);

    final transaksiList = List<Map<String, dynamic>>.from(transaksi);
    final ids = transaksiList.map((e) => e['id']).toList();

    double pendapatan = 0;
    int produkTerjual = 0;

    for (var trx in transaksiList) {
      pendapatan += (trx['total'] as num).toDouble();
    }

    if (ids.isNotEmpty) {
      final detail = await supabase
          .from('transaksi_detail')
          .select('jumlah')
          .inFilter('id_transaksi', ids);

      produkTerjual = List<Map<String, dynamic>>.from(
        detail,
      ).fold(0, (total, item) => total + (item['jumlah'] as int));
    }

    return {
      'total': pendapatan,
      'jumlah': transaksiList.length,
      'produk_terjual': produkTerjual,
    };
  }

  Future<List<Map<String, dynamic>>> getLaporanMingguan() async {
    final today = DateTime.now();
    final start = today.subtract(const Duration(days: 6));

    final result = await supabase
        .from('transaksi')
        .select('total, tanggal')
        .gte('tanggal', start.toIso8601String().split('T')[0])
        .lte('tanggal', today.toIso8601String().split('T')[0]);

    final data = List<Map<String, dynamic>>.from(result);

    Map<String, double> totalPerHari = {};

    for (var item in data) {
      final date = DateTime.parse(item['tanggal']).toLocal();
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      totalPerHari[key] =
          (totalPerHari[key] ?? 0) + (item['total'] as num).toDouble();
    }

    List<Map<String, dynamic>> resultList = [];
    for (int i = 0; i <= 6; i++) {
      final d = start.add(Duration(days: i));
      final key =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      resultList.add({'tanggal': key, 'total': totalPerHari[key] ?? 0.0});
    }

    return resultList;
  }

  Future<List<Map<String, dynamic>>> getLastTransaksi({int limit = 5}) async {
    final data = await supabase
        .from('transaksi')
        .select('id, total, tanggal')
        .order('id', ascending: false) // GANTI dari 'tanggal' ke 'id'
        .limit(limit);

    return List<Map<String, dynamic>>.from(data).map((trx) {
      return {
        'id': trx['id'],
        'total': trx['total'],
        'tanggal': trx['tanggal'],
        'formatted': DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).format(DateTime.parse(trx['tanggal'])),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getAllTransaksiHariIni(
    DateTime date,
  ) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final data = await supabase
        .from('transaksi')
        .select('id, total, tanggal')
        .gte('tanggal', start.toIso8601String().split('T')[0])
        .lt('tanggal', end.toIso8601String().split('T')[0])
        .order('tanggal', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  // -----------------------
  // laporan barang
  // -----------------------
  Future<List<Map<String, dynamic>>> getLaporanGabungan({
    required DateTime start,
    required DateTime end,
    String keyword = '',
    String jenisFilter = 'Semua',
  }) async {
    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];

    final List<Map<String, dynamic>> resultGabungan = [];

    // --------------------------
    // 1. Barang Masuk
    // --------------------------
    if (jenisFilter == 'Semua' || jenisFilter == 'Masuk') {
      final masukRes = await supabase
          .from('barang_masuk')
          .select('id_produk, jumlah, tanggal_masuk, produk(nama_brg)')
          .gte('tanggal_masuk', startStr)
          .lte('tanggal_masuk', endStr)
          .order('tanggal_masuk', ascending: false);

      final masukList = List<Map<String, dynamic>>.from(masukRes);

      final filteredMasuk =
          masukList
              .where((item) {
                final nama =
                    item['produk']?['nama_brg']?.toString().toLowerCase() ?? '';
                return keyword.isEmpty || nama.contains(keyword.toLowerCase());
              })
              .map((item) {
                return {
                  'tanggal':
                      DateTime.tryParse(item['tanggal_masuk']) ??
                      DateTime.now(),
                  'nama_brg': item['produk']?['nama_brg'] ?? 'Tidak diketahui',
                  'jumlah': item['jumlah'] ?? 0,
                  'jenis': 'Masuk',
                };
              })
              .toList();

      resultGabungan.addAll(filteredMasuk);
    }

    // --------------------------
    // 2. Barang Keluar (Transaksi)
    // --------------------------
    if (jenisFilter == 'Semua' || jenisFilter == 'Keluar') {
      // Ambil transaksi yang sesuai rentang tanggal
      final transaksiRes = await supabase
          .from('transaksi')
          .select('id, tanggal')
          .gte('tanggal', startStr)
          .lte('tanggal', endStr);

      final transaksiList = List<Map<String, dynamic>>.from(transaksiRes);
      final transaksiIds = transaksiList.map((t) => t['id']).toList();
      final transaksiTanggal = {
        for (var t in transaksiList) t['id']: t['tanggal'],
      };

      if (transaksiIds.isNotEmpty) {
        final keluarRes = await supabase
            .from('transaksi_detail')
            .select('id_transaksi, id_produk, jumlah, produk(nama_brg)')
            .inFilter('id_transaksi', transaksiIds);

        final keluarList = List<Map<String, dynamic>>.from(keluarRes);

        final filteredKeluar =
            keluarList
                .where((item) {
                  final nama =
                      item['produk']?['nama_brg']?.toString().toLowerCase() ??
                      '';
                  return keyword.isEmpty ||
                      nama.contains(keyword.toLowerCase());
                })
                .map((item) {
                  final tanggalStr =
                      transaksiTanggal[item['id_transaksi']] ?? '';
                  return {
                    'tanggal': DateTime.tryParse(tanggalStr) ?? DateTime.now(),
                    'nama_brg':
                        item['produk']?['nama_brg'] ?? 'Tidak diketahui',
                    'jumlah': item['jumlah'] ?? 0,
                    'jenis': 'Keluar',
                  };
                })
                .toList();

        resultGabungan.addAll(filteredKeluar);
      }
    }

    // Urutkan berdasarkan tanggal terbaru
    resultGabungan.sort((a, b) => b['tanggal'].compareTo(a['tanggal']));

    return resultGabungan;
  }
}
