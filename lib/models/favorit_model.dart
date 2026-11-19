import 'pasal_model.dart';

class FavoritModel {
  static const int minCatatan = 10;
  static const int maxCatatan = 200;

  static final RegExp _polaNamaDokumen =
      RegExp(r'^\[(.*?)\]\s*(.*?)\s*-\s*(.*)$');

  final int? id;
  final String userId;
  final String frbrUri;
  final String namaDokumen;
  final String catatanStudi;
  final String? createdAt;

  FavoritModel({
    this.id,
    required this.userId,
    required this.frbrUri,
    required this.namaDokumen,
    required this.catatanStudi,
    this.createdAt,
  });

  factory FavoritModel.fromJson(Map json) {
    return FavoritModel(
      id: int.tryParse((json['id'] ?? '').toString()),
      userId: (json['user_id'] ?? '').toString(),
      frbrUri: (json['frbr_uri'] ?? '').toString(),
      namaDokumen: (json['nama_dokumen'] ?? '').toString(),
      catatanStudi: (json['catatan_studi'] ?? '').toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map toJson() {
    return {
      'user_id': userId,
      'frbr_uri': frbrUri,
      'nama_dokumen': namaDokumen,
      'catatan_studi': catatanStudi,
    };
  }

  List<String> get _bagianNama {
    final match = _polaNamaDokumen.firstMatch(namaDokumen);
    if (match == null) return const [];
    return [
      match.group(1)!.trim(),
      match.group(2)!.trim(),
      match.group(3)!.trim(),
    ];
  }

  // frbr_uri pasal.id berbentuk /akn/id/act/uu/2003/13
  List<String> get _segmenUri {
    return frbrUri.split('/').where((bagian) => bagian.trim().isNotEmpty).toList();
  }

  String get jenis {
    final bagian = _bagianNama;
    if (bagian.isNotEmpty && bagian[0].isNotEmpty) return bagian[0];

    final segmen = _segmenUri;
    if (segmen.length >= 3) {
      return PasalModel.parseType(segmen[segmen.length - 3]);
    }
    return '-';
  }

  String get nomor {
    final bagian = _bagianNama;
    if (bagian.length > 1) {
      final nomorDariNama = bagian[1].split('/').first.trim();
      if (nomorDariNama.isNotEmpty) return nomorDariNama;
    }

    final segmen = _segmenUri;
    return segmen.isEmpty ? '-' : segmen.last;
  }

  String get tahun {
    final bagian = _bagianNama;
    if (bagian.length > 1) {
      final pecahan = bagian[1].split('/');
      if (pecahan.length > 1 && pecahan[1].trim().isNotEmpty) {
        return pecahan[1].trim();
      }
    }

    final segmen = _segmenUri;
    return segmen.length >= 2 ? segmen[segmen.length - 2] : '-';
  }

  String get judul {
    final bagian = _bagianNama;
    if (bagian.length > 2 && bagian[2].isNotEmpty) return bagian[2];
    return namaDokumen.isNotEmpty ? namaDokumen : 'Tanpa Judul';
  }
}
