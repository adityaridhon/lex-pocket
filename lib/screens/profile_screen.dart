import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../helpers/auth_session.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController _authController = AuthController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (AuthSession.currentUserId != null && AuthSession.currentUserProfile == null) {
      setState(() => _isLoading = true);
      await _authController.fetchUserProfile(AuthSession.currentUserId!);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogout() {
    _authController.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    double landscapeHori =
        MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right;
    double lebarLayar = MediaQuery.of(context).size.width - landscapeHori;
    double x = 18.0;
    double lebarTengah = lebarLayar - (2 * x);

    final user = AuthSession.currentUserProfile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card Profil
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 24),
              width: lebarTengah,
              decoration: const BoxDecoration(
                color: Color(0xFF006199),
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                    ),
                    child: const Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  Text(
                    user?.nama ?? 'Pengguna LexPocket',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    child: Text(
                      user?.email ?? 'Belum terautentikasi',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            // Card Detail Informasi Akun
            if (_isLoading)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 40),
                child: const CircularProgressIndicator(),
              )
            else
              Container(
                margin: EdgeInsets.symmetric(horizontal: x),
                width: lebarTengah,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Informasi Akun',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Text(
                            'Nama: ${user?.nama ?? '-'}',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Text(
                            'Email: ${user?.email ?? '-'}',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Tombol Logout
            Container(
              margin: EdgeInsets.only(top: 30, left: x, right: x, bottom: 40),
              child: GestureDetector(
                onTap: _handleLogout,
                child: Container(
                  width: lebarTengah,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Center(
                    child: Text(
                      'Keluar / Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}