import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = AuthController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isObscure = true;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password wajib diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _authController.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double landscapeHori =
        MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right;
    double lebarLayar = MediaQuery.of(context).size.width - landscapeHori;
    double x = 24.0;
    double lebarTengah = lebarLayar - (2 * x);
    double lebarDalamField = lebarTengah - 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(left: x, right: x, top: 40, bottom: 40),
            child: Column(
              children: [
                // Logo Icon Container (Di-center pakai kalkulasi Row)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(width: (lebarTengah - 80) / 2),
                      Image.asset(
                        'assets/logo-transparent.png',
                        width: 80,
                        height: 80,
                        color: const Color(0xFF006199),
                      ),
                      Container(width: (lebarTengah - 80) / 2),
                    ],
                  ),
                ),

                // Title
                Container(
                  margin: const EdgeInsets.only(bottom: 50),
                  child: Row(
                    children: [
                      Container(
                        width: lebarTengah,
                        child: const Text(
                          'Lex Pocket',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF006199),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Subtitle
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    children: [
                      Container(
                        width: lebarTengah,
                        child: const Text(
                          'Login to your Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Email Field
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: lebarTengah,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(width: 16),
                      Container(
                        width: lebarDalamField - 32,
                        child: TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(width: 16),
                    ],
                  ),
                ),

                // Password Field
                Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  width: lebarTengah,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(width: 16),
                      Container(
                        width: lebarDalamField - 64,
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _isObscure,
                          decoration: const InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                        child: Container(
                          width: 24,
                          child: Icon(
                            _isObscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                      Container(width: 16),
                    ],
                  ),
                ),

                // Tombol Sign In
                GestureDetector(
                  onTap: _isLoading ? null : _handleLogin,
                  child: Container(
                    width: lebarTengah,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006199),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        'Sign in',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // Link ke Register Screen
                Container(
                  margin: const EdgeInsets.only(top: 50, bottom: 40),
                  child: Row(
                    children: [
                      Container(
                        width: lebarTengah,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                              children: [
                                TextSpan(
                                  text: 'Sign up',
                                  style: TextStyle(
                                    color: Color(0xFF006199),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}