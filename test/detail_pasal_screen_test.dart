import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lex_pocket/helpers/auth_session.dart';
import 'package:lex_pocket/screens/detail_pasal_screen.dart';

import 'fake_backend.dart';

const Map<String, dynamic> argsDetail = {
  'type': 'UU',
  'number': '13',
  'year': '2003',
  'status': 'Berlaku',
  'title': 'UU Ketenagakerjaan',
  'frbr_uri': '/akn/id/act/uu/2003/13',
  'url': 'https://pasal.id/akn/id/act/uu/2003/13',
  'isi_lengkap': 'Teks lengkap peraturan.',
};

void main() {
  setUp(() {
    AuthSession.clearSession();
    AuthSession.currentUserId = 'user-1';
  });

  Future<void> bukaDetail(
    WidgetTester tester,
    FakeBackend backend, [
    Future<void> Function()? aksi,
  ]) async {
    await http.runWithClient(() async {
      final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          home: const Scaffold(),
          routes: {
            '/detail_pasal': (context) => const DetailPasalScreen(),
          },
        ),
      );

      navKey.currentState!.pushNamed('/detail_pasal', arguments: argsDetail);
      await tester.pumpAndSettle();

      if (aksi != null) await aksi();
    }, () => backend.client);
  }

  testWidgets('negatif: catatan kurang dari 10 karakter ditolak',
      (tester) async {
    final backend = FakeBackend();

    await bukaDetail(tester, backend, () async {
      await tester.tap(find.text('Simpan ke Favorit'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'pendek');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
    });

    expect(find.text('Catatan minimal 10 karakter.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      backend.requestLog,
      isNot(contains('POST /rest/v1/bookmark_hukum')),
    );
  });

  testWidgets('positif: simpan ke favorit mengirim data ke server',
      (tester) async {
    final backend = FakeBackend();

    await bukaDetail(tester, backend, () async {
      await tester.tap(find.text('Simpan ke Favorit'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'Penting untuk UTS Hukum Tata Negara',
      );
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
    });

    expect(find.text('Hapus dari Favorit'), findsOneWidget);
    expect(
      backend.requestLog,
      contains('POST /rest/v1/bookmark_hukum'),
    );
    expect(backend.bookmarks.length, 1);
    expect(backend.bookmarks.first['frbr_uri'], argsDetail['frbr_uri']);
    expect(
      backend.bookmarks.first['nama_dokumen'],
      '[UU] 13/2003 - UU Ketenagakerjaan',
    );
    expect(find.text('Pasal disimpan ke favorit'), findsOneWidget);
  });

  testWidgets('negatif: gagal simpan favorit menampilkan pesan',
      (tester) async {
    final backend = FakeBackend()..failBookmarkWrite = true;

    await bukaDetail(tester, backend, () async {
      await tester.tap(find.text('Simpan ke Favorit'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField),
        'Penting untuk UTS Hukum Tata Negara',
      );
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
    });

    expect(find.textContaining('Gagal menyimpan favorit'), findsOneWidget);
    expect(find.text('Simpan ke Favorit'), findsOneWidget);
    expect(backend.bookmarks, isEmpty);
  });

  testWidgets('positif: status awal favorit terbaca dari server',
      (tester) async {
    final backend = FakeBackend(bookmarks: [contohBookmark()]);

    await bukaDetail(tester, backend);

    expect(find.text('Hapus dari Favorit'), findsOneWidget);
    expect(
      backend.requestLog,
      contains('GET /rest/v1/bookmark_hukum'),
    );
  });

  testWidgets('positif: hapus favorit menghapus data di server',
      (tester) async {
    final backend = FakeBackend(bookmarks: [contohBookmark()]);

    await bukaDetail(tester, backend, () async {
      await tester.tap(find.text('Hapus dari Favorit'));
      await tester.pumpAndSettle();
    });

    expect(find.text('Simpan ke Favorit'), findsOneWidget);
    expect(
      backend.requestLog,
      contains('DELETE /rest/v1/bookmark_hukum'),
    );
    expect(backend.bookmarks, isEmpty);
    expect(find.text('Pasal dihapus dari daftar favorit'), findsOneWidget);
  });

  testWidgets('negatif: gagal hapus favorit menampilkan pesan',
      (tester) async {
    final backend = FakeBackend(bookmarks: [contohBookmark()])
      ..failBookmarkWrite = true;

    await bukaDetail(tester, backend, () async {
      await tester.tap(find.text('Hapus dari Favorit'));
      await tester.pumpAndSettle();
    });

    expect(find.textContaining('Gagal menghapus favorit'), findsOneWidget);
    expect(find.text('Hapus dari Favorit'), findsOneWidget);
    expect(backend.bookmarks.length, 1);
  });
}
