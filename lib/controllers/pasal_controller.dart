import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pasal_model.dart';

class PasalController {
  static const String _baseUrl = 'https://pasal.id/api/v1/laws';
  static const String _token = 'pasal_mcp_78a31e45f848_69a973fecbe13044afff04857097bb63ba13fcb53c0cd319';

  Future<List<PasalModel>> fetchLaws({
    int limit = 10,
    int offset = 0,
    String type = '',
  }) async {
    String urlString = '$_baseUrl?limit=$limit&offset=$offset';
    if (type.isNotEmpty) {
      urlString += '&type=$type';
    }

    final Uri url = Uri.parse(urlString);

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> lawsJson = body['laws'] ?? [];

        return lawsJson.map((json) => PasalModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi: $e');
    }
  }
}