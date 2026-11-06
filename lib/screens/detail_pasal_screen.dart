import 'package:flutter/material.dart';

class DetailPasalScreen extends StatefulWidget {
  const DetailPasalScreen({super.key});

  @override
  State<DetailPasalScreen> createState() => _DetailPasalScreenState();
}

class _DetailPasalScreenState extends State<DetailPasalScreen> {
  bool _isFavorited = false;
  final TextEditingController _catatanController = TextEditingController();

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'berlaku' || s == 'tetap') return Colors.green;
    if (s == 'diubah') return Colors.orange;
    if (s == 'dicabut') return Colors.red;
    return Colors.grey;
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    final jenis = args?['type'] ?? 'Undef';
    final nomor = args?['number'] ?? '-';
    final tahun = args?['year'] ?? '-';
    final status = args?['status'] ?? '-';
    final judul = args?['title'] ?? 'Judul Tidak Tersedia';
    final isiLengkap = args?['isi_lengkap'] ?? 'Teks pasal tidak tersedia. Hubungkan dengan API/Scraper.';

    Color statusColor = _getStatusColor(status);

    double landscapeHori = MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right;
    double lebarLayar = MediaQuery.of(context).size.width - landscapeHori;
    double x = 24.0;
    double lebarTengah = lebarLayar - (2 * x);
    double lebarTengahAppBar = lebarTengah - 48;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SizedBox(width: x),
                        SizedBox(
                          width: lebarTengah,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const SizedBox(
                                  width: 24,
                                  child: Icon(Icons.arrow_back, color: Colors.black87),
                                ),
                              ),
                              SizedBox(
                                width: lebarTengahAppBar,
                                child: const Text(
                                  'Detail Peraturan',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 24,
                                child: Icon(
                                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                                  color: _isFavorited ? const Color(0xFF006199) : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: x),
                      ],
                    ),

                    const SizedBox(height: 32),
                    Row(
                      children: [
                        SizedBox(width: x),
                        SizedBox(
                          width: lebarTengah,
                          child: Row(
                            children: [
                              Container(
                                height: 26,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        const SizedBox(width: 8),
                                        Text(
                                          jenis,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '$nomor/$tahun',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                height: 26,
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  border: Border.all(color: statusColor.withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const SizedBox(width: 10),
                                        Text(
                                          status.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: x),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        SizedBox(width: x),
                        SizedBox(
                          width: lebarTengah,
                          child: Text(
                            judul,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                          ),
                        ),
                        SizedBox(width: x),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        SizedBox(width: x),
                        Container(width: lebarTengah, height: 1, color: Colors.grey.shade200),
                        SizedBox(width: x),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Row(
                      children: [
                        SizedBox(width: x),
                        SizedBox(
                          width: lebarTengah,
                          child: Text(
                            isiLengkap,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.6,
                            ),
                          ),
                        ),
                        SizedBox(width: x),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(width: x),
                      Container(
                        width: lebarTengah,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: lebarTengah - 26,
                                  child: TextField(
                                    controller: _catatanController,
                                    maxLines: 2,
                                    decoration: const InputDecoration(
                                      hintText: 'Tulis catatan untuk pasal ini...',
                                      hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: x),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(width: x),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFavorited = !_isFavorited;
                          });
                        },
                        child: Container(
                          width: lebarTengah,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _isFavorited ? Colors.white : const Color(0xFF006199),
                            border: Border.all(
                              color: _isFavorited ? Colors.red : const Color(0xFF006199),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  SizedBox(
                                    width: lebarTengah-3,
                                    child: Text(
                                      _isFavorited ? 'Hapus dari Favorit' : 'Simpan ke Favorit',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _isFavorited ? Colors.red : Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: x),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}