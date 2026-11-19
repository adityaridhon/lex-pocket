import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lex_pocket/controllers/favorit_controller.dart';
import 'package:lex_pocket/helpers/auth_session.dart';
import 'package:lex_pocket/models/favorit_model.dart';
import 'package:lex_pocket/screens/favorit_screen.dart';

import 'fake_backend.dart';

Future<T> denganBackend<T>(FakeBackend backend, Future<T> Function() aksi) {
  return http.runWithClient(aksi, () => backend.client);
}

void main() {
  setUp(() {
    AuthSession.clearSession();
    AuthSession.currentUserId = 'user-1';
  });

  group('FavoritController', () {
    test('positif: fetchBookmarks mengembalikan daftar favorit', () async {
      final backend = FakeBackend(
        bookmarks: [
          contohBookmark(id: 1),
          contohBookmark(
            id: 2,
            frbrUri: '/akn/id/act/pp/2021/35',
            namaDokumen: '[PP] 35/2021 - Pengelolaan Sampah',
            catatan: 'Catatan kedua',
          ),
        ],
      );

      final List<FavoritModel> hasil = await denganBackend(
        backend,
        () => FavoritController().fetchBookmarks(),
      );

      expect(hasil.length, 2);
      expect(hasil.first.id, 1);
      expect(hasil.last.jenis, 'PP');
    });

    test('negatif: fetchBookmarks gagal saat server error', () async {
      final backend = FakeBackend()..failBookmarkRead = true;

      await expectLater(
        denganBackend(backend, () => FavoritController().fetchBookmarks()),
        throwsA(isA<Exception>()),
      );
    });

    test('positif: getBookmarkByUri menemukan favorit', () async {
      final backend = FakeBackend(bookmarks: [contohBookmark()]);

      final FavoritModel? hasil = await denganBackend(
        backend,
        () => FavoritController().getBookmarkByUri('/akn/id/act/uu/2003/13'),
      );

      expect(hasil, isNotNull);
      expect(hasil?.id, 1);
      expect(hasil?.catatanStudi, contains('UTS'));
    });

    test('positif: getBookmarkByUri mengembalikan null jika tidak ada',
        () async {
      final backend = FakeBackend();

      final FavoritModel? hasil = await denganBackend(
        backend,
        () => FavoritController().getBookmarkByUri('/akn/id/act/uu/1999/1'),
      );

      expect(hasil, isNull);
    });

    test('positif: addBookmark menyimpan data baru', () async {
      final backend = FakeBackend();

      final FavoritModel hasil = await denganBackend(
        backend,
        () => FavoritController().addBookmark(
          frbrUri: '/akn/id/act/uu/2003/13',
          namaDokumen: '[UU] 13/2003 - Ketenagakerjaan',
          catatanStudi: 'Catatan penting',
        ),
      );

      expect(hasil.id, isNotNull);
      expect(hasil.userId, 'user-1');
      expect(backend.bookmarks.length, 1);
      expect(backend.bookmarks.first['catatan_studi'], 'Catatan penting');
    });

    test('negatif: addBookmark gagal saat server error', () async {
      final backend = FakeBackend()..failBookmarkWrite = true;

      await expectLater(
        denganBackend(
          backend,
          () => FavoritController().addBookmark(
            frbrUri: '/akn/id/act/uu/2003/13',
            namaDokumen: '[UU] 13/2003 - Ketenagakerjaan',
            catatanStudi: 'Catatan penting',
          ),
        ),
        throwsA(isA<Exception>()),
      );

      expect(backend.bookmarks, isEmpty);
    });

    test('positif: updateCatatan mengubah catatan', () async {
      final backend = FakeBackend(bookmarks: [contohBookmark()]);

      await denganBackend(
        backend,
        () => FavoritController().updateCatatan(1, 'Catatan baru yang lebih panjang'),
      );

      expect(
        backend.bookmarks.first['catatan_studi'],
        'Catatan baru yang lebih panjang',
      );
    });

    test('negatif: updateCatatan gagal saat server error', () async {
      final backend = FakeBackend(bookmarks: [contohBookmark()])
        ..failBookmarkWrite = true;

      await expectLater(
        denganBackend(
          backend,
          () => FavoritController().updateCatatan(1, 'Catatan baru'),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('positif: deleteBookmark menghapus data', () async {
      final backend = FakeBackend(bookmarks: [contohBookmark()]);

      await denganBackend(
        backend,
        () => FavoritController().deleteBookmark(1),
      );

      expect(backend.bookmarks, isEmpty);
    });

    test('negatif: deleteBookmark gagal saat server error', () async {
      final backend = FakeBackend(bookmarks: [contohBookmark()])
        ..failBookmarkWrite = true;

      await expectLater(
        denganBackend(backend, () => FavoritController().deleteBookmark(1)),
        throwsA(isA<Exception>()),
      );

      expect(backend.bookmarks.length, 1);
    });
  });

  group('FavoritScreen', () {
    // Semua interaksi dibungkus runWithClient agar request yang dipicu
    // setelah dialog ditutup tetap memakai backend palsu.
    Future<void> bukaFavorit(
      WidgetTester tester,
      FakeBackend backend, [
      Future<void> Function()? aksi,
    ]) async {
      await denganBackend(backend, () async {
        await tester.pumpWidget(const MaterialApp(home: FavoritScreen()));
        await tester.pumpAndSettle();
        if (aksi != null) await aksi();
      });
    }

    testWidgets('positif: daftar favorit tampil dari server', (tester) async {
      final backend = FakeBackend(
        bookmarks: [
          contohBookmark(id: 1),
          contohBookmark(
            id: 2,
            frbrUri: '/akn/id/act/pp/2021/35',
            namaDokumen: '[PP] 35/2021 - Pengelolaan Sampah',
            catatan: 'Catatan kedua',
          ),
        ],
      );

      await bukaFavorit(tester, backend);

      expect(find.textContaining('Ketenagakerjaan'), findsWidgets);
      expect(find.textContaining('Pengelolaan Sampah'), findsWidgets);
    });

    testWidgets('negatif: daftar kosong menampilkan pesan', (tester) async {
      final backend = FakeBackend();

      await bukaFavorit(tester, backend);

      expect(
        find.text('Belum ada pasal favorit. Simpan pasal dari halaman detail.'),
        findsOneWidget,
      );
    });

    testWidgets('negatif: error server menampilkan pesan gagal',
        (tester) async {
      final backend = FakeBackend()..failBookmarkRead = true;

      await bukaFavorit(tester, backend);

      expect(find.textContaining('Gagal mengambil favorit'), findsOneWidget);
    });

    testWidgets('negatif: edit catatan kurang dari 10 karakter ditolak',
        (tester) async {
      final backend = FakeBackend(bookmarks: [contohBookmark()]);

      await bukaFavorit(tester, backend, () async {
        await tester.tap(find.text('Edit Catatan'));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField), 'pendek');
        await tester.tap(find.text('Simpan'));
        await tester.pumpAndSettle();
      });

      expect(find.text('Catatan minimal 10 karakter.'), findsOneWidget);
      expect(backend.requestLog, isNot(contains('PATCH /rest/v1/bookmark_hukum')));
    });

    testWidgets('positif: edit catatan tersimpan ke server', (tester) async {
      final backend = FakeBackend(bookmarks: [contohBookmark()]);

      await bukaFavorit(tester, backend, () async {
        await tester.tap(find.text('Edit Catatan'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byType(TextField),
          'Catatan hasil edit untuk ujian',
        );
        await tester.tap(find.text('Simpan'));
        await tester.pumpAndSettle();
      });

      expect(backend.requestLog, contains('PATCH /rest/v1/bookmark_hukum'));
      expect(
        backend.bookmarks.first['catatan_studi'],
        'Catatan hasil edit untuk ujian',
      );
      expect(find.text('Catatan berhasil diperbarui'), findsOneWidget);
    });

    testWidgets('negatif: batal konfirmasi hapus tidak menghapus data',
        (tester) async {
      final backend = FakeBackend(bookmarks: [contohBookmark()]);

      await bukaFavorit(tester, backend, () async {
        await tester.tap(find.text('Hapus'));
        await tester.pumpAndSettle();
        expect(find.text('Hapus Favorit'), findsOneWidget);

        await tester.tap(find.text('Batal'));
        await tester.pumpAndSettle();
      });

      expect(backend.requestLog, isNot(contains('DELETE /rest/v1/bookmark_hukum')));
      expect(backend.bookmarks.length, 1);
      expect(find.textContaining('Ketenagakerjaan'), findsWidgets);
    });

    testWidgets('positif: konfirmasi hapus menghapus data', (tester) async {
      final backend = FakeBackend(bookmarks: [contohBookmark()]);

      await bukaFavorit(tester, backend, () async {
        await tester.tap(find.text('Hapus'));
        await tester.pumpAndSettle();

        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('Hapus'),
          ),
        );
        await tester.pumpAndSettle();
      });

      expect(backend.requestLog, contains('DELETE /rest/v1/bookmark_hukum'));
      expect(backend.bookmarks, isEmpty);
      expect(find.text('Favorit berhasil dihapus'), findsOneWidget);
      expect(
        find.text('Belum ada pasal favorit. Simpan pasal dari halaman detail.'),
        findsOneWidget,
      );
    });
  });
}
