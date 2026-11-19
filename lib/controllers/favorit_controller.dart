import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helpers/auth_session.dart';
import '../models/favorit_model.dart';

class FavoritController {
  static const String _baseUrl = 'https://gjiulsmlkwdljgoxdblb.supabase.co';
  static const String _apiKey = 'sb_publishable_H3KRZ3NLVOgIqhNNAfr3HA_HiAwwAV3';
  static const String _tabel = 'bookmark_hukum';

  Map<String, String> get _headers {
    return {
      'apikey': _apiKey,
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };
  }

  String get _filterUser => 'user_id=eq.${AuthSession.currentUserId}';

  Future<List<FavoritModel>> fetchBookmarks() async {
    final Uri url = Uri.parse(
      '$_baseUrl/rest/v1/$_tabel?$_filterUser&order=created_at.desc',
    );

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return [
          for (final item in data) FavoritModel.fromJson(item),
        ];
      } else {
        throw Exception('Gagal mengambil favorit (${response.statusCode})');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<FavoritModel?> getBookmarkByUri(String frbrUri) async {
    final String uriTerenkode = Uri.encodeComponent(frbrUri);
    final Uri url = Uri.parse(
      '$_baseUrl/rest/v1/$_tabel?$_filterUser&frbr_uri=eq.$uriTerenkode&limit=1',
    );

    try {
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isEmpty) return null;
        return FavoritModel.fromJson(data.first);
      } else {
        throw Exception('Gagal cek favorit (${response.statusCode})');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<FavoritModel> addBookmark({
    required String frbrUri,
    required String namaDokumen,
    required String catatanStudi,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/rest/v1/$_tabel');

    try {
      final response = await http.post(
        url,
        headers: {..._headers, 'Prefer': 'return=representation'},
        body: jsonEncode({
          'user_id': AuthSession.currentUserId,
          'frbr_uri': frbrUri,
          'nama_dokumen': namaDokumen,
          'catatan_studi': catatanStudi,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = jsonDecode(response.body);
        if (data.isEmpty) {
          throw Exception('Respons simpan favorit kosong');
        }
        return FavoritModel.fromJson(data.first);
      } else {
        throw Exception('Gagal menyimpan favorit (${response.statusCode})');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> updateCatatan(int id, String catatanStudi) async {
    final Uri url = Uri.parse('$_baseUrl/rest/v1/$_tabel?id=eq.$id');

    try {
      final response = await http.patch(
        url,
        headers: {..._headers, 'Prefer': 'return=minimal'},
        body: jsonEncode({'catatan_studi': catatanStudi}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Gagal memperbarui catatan (${response.statusCode})');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> deleteBookmark(int id) async {
    final Uri url = Uri.parse('$_baseUrl/rest/v1/$_tabel?id=eq.$id');

    try {
      final response = await http.delete(url, headers: _headers);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Gagal menghapus favorit (${response.statusCode})');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
