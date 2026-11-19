import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lex_pocket/controllers/auth_controller.dart';
import 'package:lex_pocket/helpers/auth_session.dart';
import 'package:lex_pocket/models/user_model.dart';
import 'package:lex_pocket/screens/login_screen.dart';
import 'package:lex_pocket/screens/profile_screen.dart';
import 'package:lex_pocket/screens/register_screen.dart';

import 'fake_backend.dart';

Future<T> denganBackend<T>(FakeBackend backend, Future<T> Function() aksi) {
  return http.runWithClient(aksi, () => backend.client);
}

void main() {
  setUp(AuthSession.clearSession);

  group('AuthController.login', () {
    test('positif: menyimpan user id, token, dan profil', () async {
      final backend = FakeBackend();

      final bool berhasil = await denganBackend(
        backend,
        () => AuthController().login(
          email: 'adit@example.com',
          password: 'rahasia123',
        ),
      );

      expect(berhasil, isTrue);
      expect(AuthSession.currentUserId, 'user-1');
      expect(AuthSession.accessToken, 'token-1');
      expect(AuthSession.currentUserProfile?.nama, 'Adit');
    });

    test('negatif: password salah melempar error dan sesi kosong', () async {
      final backend = FakeBackend()..failLogin = true;

      await expectLater(
        denganBackend(
          backend,
          () => AuthController().login(
            email: 'adit@example.com',
            password: 'salah',
          ),
        ),
        throwsA(isA<Exception>()),
      );

      expect(AuthSession.isLoggedIn, isFalse);
    });
  });

  group('AuthController.register', () {
    test('positif: akun dan profil dibuat', () async {
      final backend = FakeBackend();

      final bool berhasil = await denganBackend(
        backend,
        () => AuthController().register(
          nama: 'Adit',
          email: 'adit@example.com',
          password: 'rahasia123',
        ),
      );

      expect(berhasil, isTrue);
      expect(
        backend.requestLog,
        containsAll(['POST /auth/v1/signup', 'POST /rest/v1/profil_pengguna']),
      );
    });

    test('negatif: email sudah terdaftar melempar error', () async {
      final backend = FakeBackend()..failRegister = true;

      await expectLater(
        denganBackend(
          backend,
          () => AuthController().register(
            nama: 'Adit',
            email: 'adit@example.com',
            password: 'rahasia123',
          ),
        ),
        throwsA(isA<Exception>()),
      );

      expect(backend.requestLog, isNot(contains('POST /rest/v1/profil_pengguna')));
    });
  });

  group('logout', () {
    test('positif: menghapus seluruh data sesi', () {
      AuthSession.currentUserId = 'user-1';
      AuthSession.accessToken = 'token-1';
      AuthSession.currentUserProfile =
          UserModel(id: 'user-1', nama: 'Adit', email: 'adit@example.com');

      AuthController().logout();

      expect(AuthSession.isLoggedIn, isFalse);
      expect(AuthSession.accessToken, isNull);
      expect(AuthSession.currentUserProfile, isNull);
    });

    testWidgets('positif: tombol logout kembali ke halaman login',
        (WidgetTester tester) async {
      AuthSession.currentUserId = 'user-1';
      AuthSession.currentUserProfile =
          UserModel(id: 'user-1', nama: 'Adit', email: 'adit@example.com');

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/login': (context) => const Scaffold(
                  body: Text('HALAMAN LOGIN'),
                ),
          },
          home: const ProfileScreen(),
        ),
      );

      await tester.tap(find.text('Keluar / Logout'));
      await tester.pumpAndSettle();

      expect(find.text('HALAMAN LOGIN'), findsOneWidget);
      expect(AuthSession.isLoggedIn, isFalse);
    });
  });

  group('LoginScreen', () {
    testWidgets('negatif: field kosong menampilkan pesan', (tester) async {
      final backend = FakeBackend();

      await denganBackend(backend, () async {
        await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
        await tester.tap(find.text('Sign in'));
        await tester.pumpAndSettle();
      });

      expect(find.text('Email dan password wajib diisi'), findsOneWidget);
      expect(backend.requestLog, isEmpty);
    });

    testWidgets('negatif: kredensial salah menampilkan pesan gagal',
        (tester) async {
      final backend = FakeBackend()..failLogin = true;

      await denganBackend(backend, () async {
        await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
        await tester.enterText(find.byType(TextField).at(0), 'adit@example.com');
        await tester.enterText(find.byType(TextField).at(1), 'salah');
        await tester.tap(find.text('Sign in'));
        await tester.pumpAndSettle();
      });

      expect(find.textContaining('Gagal'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('positif: login berhasil masuk ke halaman utama',
        (tester) async {
      final backend = FakeBackend();

      await denganBackend(backend, () async {
        await tester.pumpWidget(
          MaterialApp(
            routes: {
              '/main': (context) => const Scaffold(
                    body: Text('HALAMAN UTAMA'),
                  ),
            },
            home: const LoginScreen(),
          ),
        );

        await tester.enterText(find.byType(TextField).at(0), 'adit@example.com');
        await tester.enterText(find.byType(TextField).at(1), 'rahasia123');
        await tester.tap(find.text('Sign in'));
        await tester.pumpAndSettle();
      });

      expect(find.text('HALAMAN UTAMA'), findsOneWidget);
      expect(AuthSession.isLoggedIn, isTrue);
    });
  });

  group('RegisterScreen', () {
    Future<void> bukaRegister(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                ),
                child: const Text('Buka Register'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Buka Register'));
      await tester.pumpAndSettle();
    }

    testWidgets('negatif: field kosong menampilkan pesan', (tester) async {
      final backend = FakeBackend();

      await denganBackend(backend, () async {
        await bukaRegister(tester);
        await tester.tap(find.text('Sign up'));
        await tester.pumpAndSettle();
      });

      expect(find.text('Semua field wajib diisi'), findsOneWidget);
      expect(backend.requestLog, isEmpty);
    });

    testWidgets('negatif: konfirmasi password tidak cocok', (tester) async {
      final backend = FakeBackend();

      await denganBackend(backend, () async {
        await bukaRegister(tester);
        await tester.enterText(find.byType(TextField).at(0), 'Adit');
        await tester.enterText(find.byType(TextField).at(1), 'adit@example.com');
        await tester.enterText(find.byType(TextField).at(2), 'rahasia123');
        await tester.enterText(find.byType(TextField).at(3), 'beda123');
        await tester.tap(find.text('Sign up'));
        await tester.pumpAndSettle();
      });

      expect(find.text('Konfirmasi password tidak cocok'), findsOneWidget);
      expect(backend.requestLog, isEmpty);
    });

    testWidgets('negatif: email sudah terdaftar menampilkan pesan gagal',
        (tester) async {
      final backend = FakeBackend()..failRegister = true;

      await denganBackend(backend, () async {
        await bukaRegister(tester);
        await tester.enterText(find.byType(TextField).at(0), 'Adit');
        await tester.enterText(find.byType(TextField).at(1), 'adit@example.com');
        await tester.enterText(find.byType(TextField).at(2), 'rahasia123');
        await tester.enterText(find.byType(TextField).at(3), 'rahasia123');
        await tester.tap(find.text('Sign up'));
        await tester.pumpAndSettle();
      });

      expect(find.textContaining('Gagal'), findsOneWidget);
      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('positif: registrasi berhasil lalu kembali ke halaman login',
        (tester) async {
      final backend = FakeBackend();

      await denganBackend(backend, () async {
        await bukaRegister(tester);
        await tester.enterText(find.byType(TextField).at(0), 'Adit');
        await tester.enterText(find.byType(TextField).at(1), 'adit@example.com');
        await tester.enterText(find.byType(TextField).at(2), 'rahasia123');
        await tester.enterText(find.byType(TextField).at(3), 'rahasia123');
        await tester.tap(find.text('Sign up'));
        await tester.pumpAndSettle();
      });

      expect(
        find.text('Registrasi berhasil! Silakan login.'),
        findsOneWidget,
      );
      expect(find.byType(RegisterScreen), findsNothing);
      expect(find.text('Buka Register'), findsOneWidget);
    });
  });
}
