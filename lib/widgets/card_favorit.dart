import 'package:flutter/material.dart';

class CardFavorit extends StatelessWidget {
  final String jenis;
  final String nomor;
  final String tahun;
  final String status;
  final String judul;
  final String cuplikan;
  final String catatan;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CardFavorit({
    super.key,
    required this.jenis,
    required this.nomor,
    required this.tahun,
    required this.status,
    required this.judul,
    required this.cuplikan,
    required this.catatan,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'berlaku' || s == 'tetap') return Colors.green;
    if (s == 'diubah') return Colors.orange;
    if (s == 'dicabut') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    double poniHorizontal = MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right;
    double lebarLayar = MediaQuery.of(context).size.width - poniHorizontal;

    double x = 24.0;
    double y = 16.0;
    double xDalam = 14.0;

    double lebarTengah = lebarLayar - (2 * x);
    double lebarDalamKartu = lebarTengah - 2;
    double lebarKontenDalam = lebarDalamKartu - (2 * xDalam);

    double lebarTombol = (lebarKontenDalam - 8) / 2;

    Color statusColor = _getStatusColor(status);

    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: x),
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: lebarTengah,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Column(
                  children: [
                    SizedBox(height: y),
                    Row(
                      children: [
                        SizedBox(width: xDalam),
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
                                  Text(jenis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$nomor/$tahun',
                          style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
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
                                  Text(status.toUpperCase(), style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 10),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(width: xDalam),
                        SizedBox(
                          width: lebarKontenDalam,
                          child: Text(judul, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, height: 1.4)),
                        ),
                        SizedBox(width: xDalam),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        SizedBox(width: xDalam),
                        SizedBox(
                          width: lebarKontenDalam,
                          child: Text(cuplikan, style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4)),
                        ),
                        SizedBox(width: xDalam),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(width: lebarDalamKartu, height: 1, color: Colors.grey.shade200),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(width: xDalam),
                        SizedBox(
                          width: lebarKontenDalam,
                          child: Text(
                            'Catatan Saya:\n$catatan',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF006199), height: 1.4, fontStyle: FontStyle.italic),
                          ),
                        ),
                        SizedBox(width: xDalam),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        SizedBox(width: xDalam),
                        GestureDetector(
                          onTap: onEdit,
                          child: Container(
                            width: lebarTombol,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFF006199)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: lebarTombol - 2,
                                      child: const Text('Edit Catatan', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF006199), fontSize: 13, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8), 
                        GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            width: lebarTombol,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              border: Border.all(color: Colors.red.shade200),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: lebarTombol - 2,
                                      child: const Text('Hapus', textAlign: TextAlign.center, style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: xDalam),
                      ],
                    ),
                    SizedBox(height: y),
                  ],
                ),
              ),
            ),
            SizedBox(width: x),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}