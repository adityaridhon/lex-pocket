import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    double x = 24.0;
    double lebarLayar = MediaQuery.of(context).size.width;
    double lebarTengah = lebarLayar - (2 * x);
    double lebarDalam = lebarTengah - 2;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Row(
            children: [
              SizedBox(width: x),
              SizedBox(
                width: lebarTengah,
                child: Column(
                  children: [
                    const SizedBox(height: 80),
                    Row(
                      children: [
                        SizedBox(width: (lebarTengah - 80) / 2),
                        Image.asset(
                          'assets/logo-transparent.png',
                          width: 80,
                          height: 80,
                          color: const Color(0xFF006199),
                        ),
                        SizedBox(width: (lebarTengah - 80) / 2),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
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
                    const SizedBox(height: 60),
                    Row(
                      children: [
                        SizedBox(
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
                    const SizedBox(height: 24),
                    Container(
                      width: lebarTengah,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 16),
                              SizedBox(
                                width: lebarDalam - 32,
                                child: const TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Email',
                                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: lebarTengah,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 16),
                              SizedBox(
                                width: lebarDalam - 64,
                                child: TextField(
                                  obscureText: _isObscure,
                                  decoration: const InputDecoration(
                                    hintText: 'Password',
                                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                },
                                child: SizedBox(
                                  width: 24,
                                  child: Icon(
                                    _isObscure ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: lebarTengah,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/main');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006199),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Sign in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Row(
                      children: [
                        SizedBox(
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
                    const SizedBox(height: 40),
                  ],
                ),
              ),
              SizedBox(width: x),
            ],
          ),
        ),
      ),
    );
  }
}