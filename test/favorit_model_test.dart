import 'package:flutter_test/flutter_test.dart';
import 'package:lex_pocket/models/favorit_model.dart';

void main() {
  test('getter membaca nama_dokumen terstruktur', () {
    final favorit = FavoritModel(
      userId: 'user-1',
      frbrUri: '/akn/id/act/uu/2003/13',
      namaDokumen:
          '[UU] 13/2003 - Undang-Undang Nomor 13 Tahun 2003 tentang Ketenagakerjaan',
      catatanStudi: 'Penting untuk UTS',
    );

    expect(favorit.jenis, 'UU');
    expect(favorit.nomor, '13');
    expect(favorit.tahun, '2003');
    expect(favorit.judul, contains('Ketenagakerjaan'));
  });

  test('getter fallback ke frbr_uri jika nama_dokumen kosong', () {
    final favorit = FavoritModel(
      userId: 'user-1',
      frbrUri: '/akn/id/act/pp/2020/11',
      namaDokumen: '',
      catatanStudi: 'Catatan',
    );

    expect(favorit.jenis, 'PP');
    expect(favorit.nomor, '11');
    expect(favorit.tahun, '2020');
    expect(favorit.judul, 'Tanpa Judul');
  });

  test('toJson tidak mengirim id dan created_at', () {
    final favorit = FavoritModel(
      id: 9,
      userId: 'user-1',
      frbrUri: '/akn/id/act/uu/2003/13',
      namaDokumen: '[UU] 13/2003 - Judul',
      catatanStudi: 'Catatan',
      createdAt: '2026-01-01',
    );

    expect(favorit.toJson().keys, unorderedEquals([
      'user_id',
      'frbr_uri',
      'nama_dokumen',
      'catatan_studi',
    ]));
  });
}
