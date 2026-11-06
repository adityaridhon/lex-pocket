import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController _authController = AuthController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordObscure = true;
  bool _isConfirmObscure = true;
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (_namaController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi password tidak cocok')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await _authController.register(
        nama: _namaController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
        );
        Navigator.pop(context);
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
            margin: EdgeInsets.only(left: x, right: x, top: 20, bottom: 40),
            child: Column(
              children: [
                // Tombol Kembali (Back)
                Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 24,
                          child: const Icon(Icons.arrow_back, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),

                // Title
                Container(
                  margin: const EdgeInsets.only(bottom: 40),
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
                          'Create your Account',
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

                // Field Nama Lengkap
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
                          controller: _namaController,
                          decoration: const InputDecoration(
                            hintText: 'Nama Lengkap',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(width: 16),
                    ],
                  ),
                ),

                // Field Email
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

                // Field Password
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
                        width: lebarDalamField - 64,
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _isPasswordObscure,
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
                            _isPasswordObscure = !_isPasswordObscure;
                          });
                        },
                        child: Container(
                          width: 24,
                          child: Icon(
                            _isPasswordObscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                      Container(width: 16),
                    ],
                  ),
                ),

                // Field Confirm Password
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
                          controller: _confirmPasswordController,
                          obscureText: _isConfirmObscure,
                          decoration: const InputDecoration(
                            hintText: 'Confirm Password',
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isConfirmObscure = !_isConfirmObscure;
                          });
                        },
                        child: Container(
                          width: 24,
                          child: Icon(
                            _isConfirmObscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                      Container(width: 16),
                    ],
                  ),
                ),

                // Tombol Sign Up
                GestureDetector(
                  onTap: _isLoading ? null : _handleRegister,
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
                        'Sign up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                // Link Kembali ke Sign In
                Container(
                  margin: const EdgeInsets.only(top: 40, bottom: 40),
                  child: Row(
                    children: [
                      Container(
                        width: lebarTengah,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                              children: [
                                TextSpan(
                                  text: 'Sign in',
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