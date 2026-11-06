import 'package:flutter/material.dart';

class CardPasal extends StatelessWidget {
  final String jenis;
  final String nomor;
  final String tahun;
  final String status;
  final String judul;
  final String cuplikan;
  final String? catatan;
  final VoidCallback? onEditCatatan;
  final VoidCallback onTap;

  const CardPasal({
    super.key,
    required this.jenis,
    required this.nomor,
    required this.tahun,
    required this.status,
    required this.judul,
    required this.cuplikan,
    required this.onTap,
    this.catatan,
    this.onEditCatatan,
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
    // --- KALKULASI MAZHAB GRID ABSOLUT ---
    double landscapeHori =
        MediaQuery.of(context).padding.left +
            MediaQuery.of(context).padding.right;
    double lebarLayar = MediaQuery.of(context).size.width - landscapeHori;

    double x = 18.0;
    double y = 16.0;
    double xDalam = 14.0;

    double lebarTengah = lebarLayar - (2 * x);
    double lebarDalamKartu = lebarTengah - 2; // dikurangi border 1px kiri-kanan
    double lebarKontenDalam = lebarDalamKartu - (2 * xDalam);

    Color statusColor = _getStatusColor(status);

    return Column(
      children: [
        Row(
          children: [
            Container(width: x),
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: lebarTengah,
                padding: EdgeInsets.symmetric(horizontal: xDalam, vertical: y),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: Column(
                  children: [
                    // --- ROW 1: TAGS (JENIS, NOMOR/TAHUN, STATUS) ---
                    Row(
                      children: [
                        // Badge Jenis
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            jenis,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),

                        Container(width: 8),

                        // Nomor / Tahun (di-wrap Expanded agar tidak overflow)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: Text(
                              '$nomor/$tahun',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        // Badge Status
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            border: Border.all(color: statusColor.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // --- ROW 2: JUDUL KARTU ---
                    Row(
                      children: [
                        Container(
                          width: lebarKontenDalam,
                          margin: const EdgeInsets.only(top: 12),
                          child: Text(
                            judul,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // --- ROW 3: CUPLIKAN KARTU ---
                    Row(
                      children: [
                        Container(
                          width: lebarKontenDalam,
                          margin: const EdgeInsets.only(top: 8),
                          child: Text(
                            cuplikan,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(width: x),
          ],
        ),

        Container(height: 16),
      ],
    );
  }
}