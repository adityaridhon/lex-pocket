import '../models/user_model.dart';

class AuthSession {
  static String? currentUserId;
  static String? accessToken;
  static UserModel? currentUserProfile;

  static bool get isLoggedIn => currentUserId != null;

  static void clearSession() {
    currentUserId = null;
    accessToken = null;
    currentUserProfile = null;
  }
}