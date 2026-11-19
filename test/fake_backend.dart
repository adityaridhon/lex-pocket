import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Backend palsu untuk Supabase (auth + bookmark) dan API pasal.id.
/// Semua request HTTP aplikasi diarahkan ke sini lewat http.runWithClient.
class FakeBackend {
  final List<Map<String, dynamic>> bookmarks;
  final List<Map<String, dynamic>> laws;
  final List<String> requestLog = [];

  bool failLogin = false;
  bool failRegister = false;
  bool failLaws = false;
  bool failBookmarkRead = false;
  bool failBookmarkWrite = false;

  int _nextId = 1;

  FakeBackend({
    List<Map<String, dynamic>>? bookmarks,
    List<Map<String, dynamic>>? laws,
  })  : bookmarks = bookmarks ?? [],
        laws = laws ?? [];

  MockClient get client => MockClient(_handle);

  http.Response _json(Object body, [int statusCode = 200]) {
    return http.Response(
      jsonEncode(body),
      statusCode,
      headers: {'content-type': 'application/json'},
    );
  }

  Future<http.Response> _handle(http.Request request) async {
    final String path = request.url.path;
    requestLog.add('${request.method} $path');

    if (path == '/auth/v1/token') {
      if (failLogin) {
        return _json(
          {'error_description': 'Email atau password salah'},
          400,
        );
      }
      return _json({
        'user': {'id': 'user-1'},
        'access_token': 'token-1',
      });
    }

    if (path == '/auth/v1/signup') {
      if (failRegister) {
        return _json({'msg': 'User already registered'}, 422);
      }
      return _json({
        'user': {'id': 'user-1'},
      }, 201);
    }

    if (path == '/rest/v1/profil_pengguna') {
      if (request.method == 'POST') return http.Response('', 201);
      return _json({
        'id': 'user-1',
        'nama': 'Adit',
        'email': 'adit@example.com',
      });
    }

    if (path == '/api/v1/laws' || path == '/api/v1/search') {
      if (failLaws) return http.Response('error', 500);
      final String key = path == '/api/v1/laws' ? 'laws' : 'results';
      return _json({key: laws});
    }

    if (path == '/rest/v1/bookmark_hukum') {
      return _bookmark(request);
    }

    return http.Response('not found', 404);
  }

  Future<http.Response> _bookmark(http.Request request) async {
    if (request.method == 'GET') {
      if (failBookmarkRead) return http.Response('error', 500);

      final String? filter = request.url.queryParameters['frbr_uri'];
      if (filter != null) {
        final String uri = filter.replaceFirst('eq.', '');
        final List<Map<String, dynamic>> hasil =
            bookmarks.where((item) => item['frbr_uri'] == uri).toList();
        return _json(hasil.take(1).toList());
      }

      return _json(bookmarks);
    }

    if (request.method == 'POST') {
      if (failBookmarkWrite) return http.Response('error', 500);

      final Map body = jsonDecode(request.body);
      final Map<String, dynamic> item = {
        'id': _nextId++,
        'user_id': body['user_id'],
        'frbr_uri': body['frbr_uri'],
        'nama_dokumen': body['nama_dokumen'],
        'catatan_studi': body['catatan_studi'],
        'created_at': '2026-01-01T00:00:00Z',
      };
      bookmarks.insert(0, item);
      return _json([item], 201);
    }

    final String? idFilter = request.url.queryParameters['id'];
    final int? id = idFilter == null
        ? null
        : int.tryParse(idFilter.replaceFirst('eq.', ''));

    if (request.method == 'PATCH') {
      if (failBookmarkWrite) return http.Response('error', 500);

      final Map body = jsonDecode(request.body);
      for (final item in bookmarks) {
        if (item['id'] == id) item['catatan_studi'] = body['catatan_studi'];
      }
      return http.Response('', 204);
    }

    if (request.method == 'DELETE') {
      if (failBookmarkWrite) return http.Response('error', 500);

      bookmarks.removeWhere((item) => item['id'] == id);
      return http.Response('', 204);
    }

    return http.Response('not found', 404);
  }
}

Map<String, dynamic> contohBookmark({
  int id = 1,
  String frbrUri = '/akn/id/act/uu/2003/13',
  String namaDokumen =
      '[UU] 13/2003 - Undang-Undang Nomor 13 Tahun 2003 tentang Ketenagakerjaan',
  String catatan = 'Penting untuk UTS Hukum Tata Negara',
}) {
  return {
    'id': id,
    'user_id': 'user-1',
    'frbr_uri': frbrUri,
    'nama_dokumen': namaDokumen,
    'catatan_studi': catatan,
    'created_at': '2026-01-01T00:00:00Z',
  };
}

Map<String, dynamic> contohPasal({
  String type = 'uu',
  String number = '13',
  String year = '2003',
  String status = 'Berlaku',
  String title = 'Undang-Undang Nomor 13 Tahun 2003 tentang Ketenagakerjaan',
  String frbrUri = '/akn/id/act/uu/2003/13',
}) {
  return {
    'type': type,
    'number': number,
    'year': year,
    'status': status,
    'title': title,
    'frbr_uri': frbrUri,
    'url': 'https://pasal.id$frbrUri',
    'snippet': 'Ketentuan umum tentang ketenagakerjaan.',
  };
}
