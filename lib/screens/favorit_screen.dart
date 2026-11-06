import 'package:flutter/material.dart';
import 'package:lex_pocket/widgets/card_favorit.dart';

class FavoritScreen extends StatefulWidget {
  const FavoritScreen({super.key});

  @override
  State<FavoritScreen> createState() => _FavoritScreenState();
}

class _FavoritScreenState extends State<FavoritScreen> {
  final List<Map<String, dynamic>> _dataFavorit = [
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
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    double poniHorizontal = MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right;
    double lebarLayar = MediaQuery.of(context).size.width - poniHorizontal;

    double x = 24.0;
    double lebarTengah = lebarLayar - (2 * x);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: lebarLayar,
              decoration: const BoxDecoration(
                color: Color(0xFF006199),
                borderRadius: BorderRadius.only(bottomRight: Radius.circular(40), bottomLeft: Radius.circular(40)),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(width: x),
                        SizedBox(
                          width: lebarTengah,
                          child: Row(
                            children: [
                              const SizedBox(width: 28, child: Icon(Icons.favorite, color: Colors.white, size: 28)),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: lebarTengah - 40,
                                child: const Text('Pasal Favorit', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: x),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                SizedBox(width: x),
                SizedBox(
                  width: lebarTengah,
                  child: const Text('Disimpan oleh Anda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: x),
              ],
            ),
            const SizedBox(height: 16),

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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}