import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../helpers/auth_session.dart';

class AuthController {
  static const String _baseUrl = 'https://gjiulsmlkwdljgoxdblb.supabase.co';
  static const String _apiKey = 'sb_publishable_H3KRZ3NLVOgIqhNNAfr3HA_HiAwwAV3';

  // Regis contrrl
  Future<bool> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    // Hit Supabase Auth
    final Uri signupUrl = Uri.parse('$_baseUrl/auth/v1/signup');
    try {
      final authResponse = await http.post(
        signupUrl,
        headers: {
          'apikey': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (authResponse.statusCode == 200 || authResponse.statusCode == 201) {
        final authData = jsonDecode(authResponse.body);
        final String newUserId = authData['user']['id'];

        // Insert Profil ke tabel profil_pengguna
        final Uri profilUrl = Uri.parse('$_baseUrl/rest/v1/profil_pengguna');
        final profilResponse = await http.post(
          profilUrl,
          headers: {
            'apikey': _apiKey,
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'id': newUserId,
            'nama': nama,
            'email': email,
          }),
        );

        return profilResponse.statusCode == 201 || profilResponse.statusCode == 200;
      } else {
        final err = jsonDecode(authResponse.body);
        throw Exception(err['msg'] ?? err['error_description'] ?? 'Registrasi gagal');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Lgin control
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final Uri loginUrl = Uri.parse('$_baseUrl/auth/v1/token?grant_type=password');

    try {
      final response = await http.post(
        loginUrl,
        headers: {
          'apikey': _apiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Simpan variabel dalam helpre AuthSession
        AuthSession.currentUserId = data['user']['id'];
        AuthSession.accessToken = data['access_token'];

        // Ambil data profil
        await fetchUserProfile(AuthSession.currentUserId!);
        return true;
      } else {
        final err = jsonDecode(response.body);
        throw Exception(err['error_description'] ?? 'Email atau password salah');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Data prfile
  Future<UserModel?> fetchUserProfile(String userId) async {
    final Uri url = Uri.parse('$_baseUrl/rest/v1/profil_pengguna?id=eq.$userId');

    try {
      final response = await http.get(
        url,
        headers: {
          'apikey': _apiKey,
          'Authorization': 'Bearer $_apiKey',
          'Accept': 'application/vnd.pgrst.object+json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userModel = UserModel.fromJson(data);
        AuthSession.currentUserProfile = userModel;
        return userModel;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // LOGOUT
  void logout() {
    AuthSession.clearSession();
  }
}