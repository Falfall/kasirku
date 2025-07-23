import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../models/produk.dart';
import '../models/transaksi.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient client = Supabase.instance.client;

  // Authentication
  Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async => await client.auth.signOut();
  User? get currentUser => client.auth.currentUser;

  // Produk
  Future<List<Produk>> fetchProduk() async {
    final response = await client
        .from('produk')
        .select('*')
        .order('nama_brg', ascending: true);

    return response is List
        ? response.map((item) => Produk.fromJson(item as Map<String, dynamic>)).toList()
        : [];
  }

  Future<void> insertProduk({
    required int idProduk,
    required String namaBrg,
    String? suplier,
    double? harga,
  }) async {
    await client.from('produk').insert({
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
    await client
        .from('produk')
        .update({'nama_brg': namaBrg, 'suplier': suplier, 'harga': harga})
        .eq('id_produk', idProduk);
  }

  Future<void> deleteProduk(int idProduk) async {
    await client.from('produk').delete().eq('id_produk', idProduk);
  }

  // Barang Masuk
  Future<void> insertBarangMasuk({
    required int idProduk,
    required int jumlah,
    DateTime? tanggalMasuk,
  }) async {
    await client.from('barang_masuk').insert({
      'id_produk': idProduk,
      'jumlah': jumlah,
      'tanggal_masuk': (tanggalMasuk ?? DateTime.now()).toIso8601String().split('T')[0],
    });
  }

  // Transaksi
  Future<void> insertTransaksi(
    Transaksi transaksi,
    List<TransaksiDetail> detailList,
  ) async {
    final trxRes = await client
        .from('transaksi')
        .insert({
          'total': transaksi.total,
          'tanggal': DateTime.now().toIso8601String().split('T')[0],
        })
        .select()
        .single();

    final idTransaksi = trxRes['id'];

    final detailData = detailList.map((d) {
      return {
        'id_transaksi': idTransaksi,
        'id_produk': d.idProduk,
        'jumlah': d.jumlah,
        'harga': d.harga,
      };
    }).toList();

    await client.from('transaksi_detail').insert(detailData);
  }

  Future<int> simpanTransaksiDanKembalikanId(
    Transaksi transaksi,
    List<TransaksiDetail> detailList,
  ) async {
    try {
      final trxRes = await client
          .from('transaksi')
          .insert({
            'total': transaksi.total,
            'tanggal': DateTime.now().toIso8601String().split('T')[0],
          })
          .select()
          .single();

      final int idTransaksi = trxRes['id'];

      final detailData = detailList.map((d) {
        return {
          'id_transaksi': idTransaksi,
          'id_produk': d.idProduk,
          'jumlah': d.jumlah,
          'harga': d.harga,
        };
      }).toList();

      await client.from('transaksi_detail').insert(detailData);
      return idTransaksi;
    } catch (e) {
      throw Exception('Gagal menyimpan transaksi dan detail: $e');
    }
  }

  // Laporan Harian
  Future<Map<String, dynamic>> getLaporanHarian(DateTime date) async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = startDate.add(Duration(days: 1));

    final transaksi = await client
        .from('transaksi')
        .select('id, total, tanggal')
        .gte('tanggal', startDate.toIso8601String().split('T')[0])
        .lt('tanggal', endDate.toIso8601String().split('T')[0]);

    final transaksiList = List<Map<String, dynamic>>.from(transaksi);
    final ids = transaksiList.map((e) => e['id']).toList();

    double pendapatan = transaksiList.fold(0, (sum, t) => sum + (t['total'] as num).toDouble());
    int produkTerjual = 0;

    if (ids.isNotEmpty) {
      final detail = await client
          .from('transaksi_detail')
          .select('jumlah')
          .inFilter('id_transaksi', ids);

      produkTerjual = List<Map<String, dynamic>>.from(detail)
          .fold(0, (sum, item) => sum + (item['jumlah'] as int));
    }

    return {
      'total': pendapatan,
      'jumlah': transaksiList.length,
      'produk_terjual': produkTerjual,
    };
  }

  // Laporan Mingguan
  Future<List<Map<String, dynamic>>> getLaporanMingguan() async {
    final today = DateTime.now();
    final start = today.subtract(Duration(days: 6));

    final result = await client
        .from('transaksi')
        .select('total, tanggal')
        .gte('tanggal', start.toIso8601String().split('T')[0])
        .lte('tanggal', today.toIso8601String().split('T')[0]);

    final data = List<Map<String, dynamic>>.from(result);
    final totalPerHari = <String, double>{};

    for (var item in data) {
      final date = DateTime.parse(item['tanggal']).toLocal();
      final key = DateFormat('yyyy-MM-dd').format(date);
      totalPerHari[key] = (totalPerHari[key] ?? 0) + (item['total'] as num).toDouble();
    }

    return List.generate(7, (i) {
      final d = start.add(Duration(days: i));
      final key = DateFormat('yyyy-MM-dd').format(d);
      return {'tanggal': key, 'total': totalPerHari[key] ?? 0.0};
    });
  }

  Future<List<Map<String, dynamic>>> getLastTransaksi({int limit = 5}) async {
    final data = await client
        .from('transaksi')
        .select('id, total, tanggal')
        .order('id', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(data).map((trx) {
      return {
        'id': trx['id'],
        'total': trx['total'],
        'tanggal': trx['tanggal'],
        'formatted': DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.parse(trx['tanggal'])),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getAllTransaksiHariIni(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(Duration(days: 1));

    final data = await client
        .from('transaksi')
        .select('id, total, tanggal')
        .gte('tanggal', start.toIso8601String().split('T')[0])
        .lt('tanggal', end.toIso8601String().split('T')[0])
        .order('tanggal', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  // Laporan Gabungan
  Future<List<Map<String, dynamic>>> getLaporanGabungan({
    required DateTime start,
    required DateTime end,
    String keyword = '',
    String jenisFilter = 'Semua',
  }) async {
    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];

    final resultGabungan = <Map<String, dynamic>>[];

    // Barang Masuk
    if (jenisFilter == 'Semua' || jenisFilter == 'Masuk') {
      final masukRes = await client
          .from('barang_masuk')
          .select('id_produk, jumlah, tanggal_masuk, produk(nama_brg)')
          .gte('tanggal_masuk', startStr)
          .lte('tanggal_masuk', endStr)
          .order('tanggal_masuk', ascending: false);

      final masukList = List<Map<String, dynamic>>.from(masukRes);

      resultGabungan.addAll(
        masukList.where((item) {
          final nama = item['produk']?['nama_brg']?.toString().toLowerCase() ?? '';
          return keyword.isEmpty || nama.contains(keyword.toLowerCase());
        }).map((item) {
          return {
            'tanggal': DateTime.tryParse(item['tanggal_masuk']) ?? DateTime.now(),
            'nama_brg': item['produk']?['nama_brg'] ?? 'Tidak diketahui',
            'jumlah': item['jumlah'] ?? 0,
            'jenis': 'Masuk',
          };
        }),
      );
    }

    // Barang Keluar
    if (jenisFilter == 'Semua' || jenisFilter == 'Keluar') {
      final transaksiRes = await client
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
        final keluarRes = await client
            .from('transaksi_detail')
            .select('id_transaksi, id_produk, jumlah, produk(nama_brg)')
            .inFilter('id_transaksi', transaksiIds);

        final keluarList = List<Map<String, dynamic>>.from(keluarRes);

        resultGabungan.addAll(
          keluarList.where((item) {
            final nama = item['produk']?['nama_brg']?.toString().toLowerCase() ?? '';
            return keyword.isEmpty || nama.contains(keyword.toLowerCase());
          }).map((item) {
            return {
              'tanggal': DateTime.tryParse(transaksiTanggal[item['id_transaksi']]) ?? DateTime.now(),
              'nama_brg': item['produk']?['nama_brg'] ?? 'Tidak diketahui',
              'jumlah': item['jumlah'] ?? 0,
              'jenis': 'Keluar',
            };
          }),
        );
      }
    }

    resultGabungan.sort((a, b) => b['tanggal'].compareTo(a['tanggal']));
    return resultGabungan;
  }
}
