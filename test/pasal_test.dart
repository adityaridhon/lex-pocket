import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lex_pocket/controllers/pasal_controller.dart';
import 'package:lex_pocket/helpers/auth_session.dart';
import 'package:lex_pocket/models/pasal_model.dart';
import 'package:lex_pocket/screens/detail_pasal_screen.dart';
import 'package:lex_pocket/screens/pasal_screen.dart';

import 'fake_backend.dart';

Future<T> denganBackend<T>(FakeBackend backend, Future<T> Function() aksi) {
  return http.runWithClient(aksi, () => backend.client);
}

void main() {
  setUp(AuthSession.clearSession);

  group('PasalController.fetchLaws', () {
    test('positif: mengembalikan daftar peraturan', () async {
      final backend = FakeBackend(
        laws: [
          contohPasal(),
          contohPasal(
            type: 'pp',
            number: '35',
            year: '2021',
            title: 'Peraturan Pemerintah tentang Pengelolaan Sampah',
            frbrUri: '/akn/id/act/pp/2021/35',
          ),
        ],
      );

      final List<PasalModel> hasil = await denganBackend(
        backend,
        () async =>
            (await PasalController().fetchLaws()) as List<PasalModel>,
      );

      expect(hasil.length, 2);
      expect(hasil.first.type, 'UU');
      expect(hasil.first.title, contains('Ketenagakerjaan'));
      expect(hasil.last.type, 'PP');
    });

    test('negatif: server error melempar exception', () async {
      final backend = FakeBackend()..failLaws = true;

      await expectLater(
        denganBackend(backend, () => PasalController().fetchLaws()),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('PasalScreen', () {
    Future<void> bukaPasal(WidgetTester tester, FakeBackend backend) async {
      await denganBackend(backend, () async {
        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/detail_pasal': (context) => const DetailPasalScreen(),
            },
            home: const PasalScreen(),
          ),
        );
        await tester.pumpAndSettle();
      });
    }

    testWidgets('positif: semua peraturan tampil', (tester) async {
      final backend = FakeBackend(
        laws: [
          contohPasal(),
          contohPasal(
            type: 'pp',
            number: '35',
            year: '2021',
            title: 'Peraturan Pemerintah tentang Pengelolaan Sampah',
            frbrUri: '/akn/id/act/pp/2021/35',
          ),
        ],
      );

      await bukaPasal(tester, backend);

      expect(find.text('Peraturan Terbaru'), findsOneWidget);
      expect(
        find.textContaining('Ketenagakerjaan'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Pengelolaan Sampah'),
        findsOneWidget,
      );
    });

    testWidgets('negatif: error server menampilkan pesan gagal',
        (tester) async {
      final backend = FakeBackend()..failLaws = true;

      await bukaPasal(tester, backend);

      expect(find.textContaining('Gagal mengambil data'), findsOneWidget);
    });

    testWidgets('negatif: daftar kosong menampilkan pesan kosong',
        (tester) async {
      final backend = FakeBackend(laws: []);

      await bukaPasal(tester, backend);

      expect(
        find.text('Tidak ada peraturan yang ditemukan.'),
        findsOneWidget,
      );
    });

    testWidgets('positif: ketuk kartu membuka detail pasal', (tester) async {
      final backend = FakeBackend(laws: [contohPasal()]);

      await bukaPasal(tester, backend);

      await tester.tap(find.textContaining('Ketenagakerjaan').first);
      await tester.pumpAndSettle();

      expect(find.text('Detail Peraturan'), findsOneWidget);
      expect(find.textContaining('Ketenagakerjaan'), findsWidgets);
    });
  });
}
