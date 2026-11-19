import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pasal_model.dart';

class PasalController {
  static const String _host = 'pasal.id';
  static const String _token =
      'pasal_mcp_78a31e45f848_69a973fecbe13044afff04857097bb63ba13fcb53c0cd319';

  Future fetchLaws({
    int limit = 15,
    int offset = 0,
    String type = '',
  }) async {
    final queryParams = {
      'limit': limit.toString(),
      'offset': offset.toString(),
      if (type.isNotEmpty) 'type': type,
    };

    final Uri url = Uri.https(_host, '/api/v1/laws', queryParams);

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map body = jsonDecode(response.body);
        final List lawsJson = body['laws'] ?? [];
        return [
          for (final json in lawsJson) PasalModel.fromJson(json),
        ];
      } else {
        throw Exception('Gagal mengambil data (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi: $e');
    }
  }

  Future searchLaws({
    required String query,
    int limit = 15,
    int offset = 0,
    String type = '',
  }) async {
    final queryParams = {
      'q': query.trim(),
      'limit': limit.toString(),
      'offset': offset.toString(),
      if (type.isNotEmpty) 'type': type,
    };

    final Uri url = Uri.https(_host, '/api/v1/search', queryParams);

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map body = jsonDecode(response.body);
        final List rawList =
            body['results'] ?? body['laws'] ?? body['data'] ?? [];

        return [
          for (final item in rawList) PasalModel.fromJson(item),
        ];
      } else {
        throw Exception('Pencarian gagal (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi pencarian: $e');
    }
  }
}