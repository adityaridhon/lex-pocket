import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isPasswordObscure = true;
  bool _isConfirmObscure = true;

  @override
  Widget build(BuildContext context) {
    double x = 24.0;
    double lebarLayar = MediaQuery.of(context).size.width;
    double lebarTengah = lebarLayar - (2 * x);
    double lebarDalamField = lebarTengah - 2;

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
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const SizedBox(
                            width: 24,
                            child: Icon(Icons.arrow_back, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
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
                                width: lebarDalamField - 32,
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
                                width: lebarDalamField - 64,
                                child: TextField(
                                  obscureText: _isPasswordObscure,
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
                                    _isPasswordObscure = !_isPasswordObscure;
                                  });
                                },
                                child: SizedBox(
                                  width: 24,
                                  child: Icon(
                                    _isPasswordObscure ? Icons.visibility_off : Icons.visibility,
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
                                width: lebarDalamField - 64,
                                child: TextField(
                                  obscureText: _isConfirmObscure,
                                  decoration: const InputDecoration(
                                    hintText: 'Confirm Password',
                                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isConfirmObscure = !_isConfirmObscure;
                                  });
                                },
                                child: SizedBox(
                                  width: 24,
                                  child: Icon(
                                    _isConfirmObscure ? Icons.visibility_off : Icons.visibility,
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
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006199),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Sign up',
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