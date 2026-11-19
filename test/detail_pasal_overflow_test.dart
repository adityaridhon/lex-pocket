import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lex_pocket/screens/detail_pasal_screen.dart';

void main() {
  testWidgets('detail tidak overflow di layar sempit', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

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

    navKey.currentState!.pushNamed(
      '/detail_pasal',
      arguments: {
        'type': 'Putusan MK',
        'number': '123',
        'year': '2024',
        'status': 'Berlaku',
        'title': 'Putusan Mahkamah Konstitusi Nomor 123 Tahun 2024 tentang Pengujian Undang-Undang',
        'frbr_uri': '/akn/id/act/putusan_mk/2024/123',
        'isi_lengkap': 'Naskah lengkap.',
      },
    );

    await tester.pumpAndSettle();

    expect(find.text('Detail Peraturan'), findsOneWidget);
  });
}
