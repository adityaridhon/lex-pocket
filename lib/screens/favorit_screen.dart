import 'package:flutter/material.dart';
import '../widgets/card_favorit.dart';

class FavoritScreen extends StatefulWidget {
  const FavoritScreen({super.key});

  @override
  State<FavoritScreen> createState() => _FavoritScreenState();
}

class _FavoritScreenState extends State<FavoritScreen> {
  final List _dataFavorit = [
  {
  "id": 1,
  "type": "UUD",
  "number": "1945",
  "year": "2020",
  "status": "Tetap",
  "title": "Undang-Undang Dasar Negara Republik Indonesia Tahun 1945",
  "cuplikan": "Pasal 28E Ayat (3): Setiap orang berhak atas kebebasan berserikat, berkumpul, dan mengeluarkan pendapat.",
  "catatan": "Penting untuk UTS Hukum Tata Negara besok.",
  "isi_lengkap": "Teks lengkap UUD 1945..."
  },
  {
  "id": 2,
  "type": "UU",
  "number": "13",
  "year": "2003",
  "status": "Diubah",
  "title": "Undang-Undang Nomor 13 Tahun 2003 tentang Ketenagakerjaan",
  "cuplikan": "Pasal 77 Ayat (2): Waktu kerja sebagaimana dimaksud dalam ayat (1) meliputi...",
  "catatan": "Revisi batasan jam lembur.",
  "isi_lengkap": "Teks lengkap UU Ketenagakerjaan..."
  },
  ];

  void _hapusFavorit(int index) {
    setState(() {
      _dataFavorit.removeAt(index);
    });
  }

  void _editCatatan(int index) {
    TextEditingController editController = TextEditingController(text: _dataFavorit[index]['catatan']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Catatan'),
          content: TextField(
            controller: editController,
            maxLines: 3,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _dataFavorit[index]['catatan'] = editController.text;
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006199)),
              child: const Text('Simpan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- KALKULASI MAZHAB GRID ---
    double landscapeHori =
        MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right;
    double lebarLayar = MediaQuery.of(context).size.width - landscapeHori;
    double x = 18.0;
    double lebarTengah = lebarLayar - (2 * x);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER CONTAINER (SAMAKAN DENGAN PASAL & PROFIL) ---
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF006199),
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: const Icon(Icons.favorite, color: Colors.white, size: 28),
                      ),
                      Container(
                        child: const Text(
                          'Pasal Favorit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- JUDUL SECTION ---
            Container(
              margin: EdgeInsets.only(left: x, right: x, bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: lebarTengah,
                    child: const Text(
                      'Disimpan oleh Anda',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // --- LIST CARD FAVORIT ---
            ...List.generate(_dataFavorit.length, (index) {
              final data = _dataFavorit[index];
              return CardFavorit(
                jenis: data['type'],
                nomor: data['number']?.toString() ?? '-',
                tahun: data['year']?.toString() ?? '-',
                status: data['status'],
                judul: data['title'],
                cuplikan: data['cuplikan'],
                catatan: data['catatan'],
                onTap: () {
                  Navigator.pushNamed(context, '/detail_pasal', arguments: data);
                },
                onEdit: () => _editCatatan(index),
                onDelete: () => _hapusFavorit(index),
              );
            }),

            // Margin Bawah Pengganti SizedBox
            Container(
              margin: const EdgeInsets.only(bottom: 40),
            ),
          ],
        ),
      ),
    );
  }
}