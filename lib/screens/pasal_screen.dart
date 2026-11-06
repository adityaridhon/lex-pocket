import 'package:flutter/material.dart';
import '../controllers/pasal_controller.dart';
import '../models/pasal_model.dart';
import '../widgets/card_pasal.dart';

class PasalScreen extends StatefulWidget {
  const PasalScreen({super.key});

  @override
  State<PasalScreen> createState() => _PasalScreenState();
}

class _PasalScreenState extends State<PasalScreen> {
  // Instansiasi Controller
  final PasalController _pasalController = PasalController();

  List<PasalModel> _listPasal = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchPasalData();
  }

  // Fungsi async untuk mengambil data pasal dari Controller
  Future<void> _fetchPasalData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await _pasalController.fetchLaws(limit: 10, offset: 0);
      setState(() {
        _listPasal = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double landscapeHori =
        MediaQuery.of(context).padding.left +
            MediaQuery.of(context).padding.right;
    double lebarLayar = MediaQuery.of(context).size.width - landscapeHori;
    double x = 18;
    double lebarTengah = lebarLayar - (2 * x);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER CONTAINER ---
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF006199),
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: const Text(
                      'Selamat datang,',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  const Text(
                    'Aditya Ridho',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Search Field Container
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari nomor, tahun, atau judul...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- JUDUL SECTION ---
            Container(
              margin: EdgeInsets.only(left: x, right: x, bottom: 16),
              width: lebarTengah,
              child: const Text(
                'Peraturan Terbaru',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            // --- STATE CONTROL (LOADING / ERROR / LIVE DATA) ---
            if (_isLoading)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 40),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else
              ..._listPasal.map((pasal) {
                return CardPasal(
                  jenis: pasal.type,
                  nomor: pasal.number,
                  tahun: pasal.year,
                  status: pasal.status,
                  judul: pasal.title,
                  cuplikan: 'Klik untuk melihat metadata dan tautan pasal resmi...',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/detail_pasal',
                      arguments: {
                        'type': pasal.type,
                        'number': pasal.number,
                        'year': pasal.year,
                        'status': pasal.status,
                        'title': pasal.title,
                        'frbr_uri': pasal.frbrUri,
                        'url': pasal.url,
                        'isi_lengkap': 'Teks resmi dapat diakses melalui portal pasal.id.',
                      },
                    );
                  },
                );
              }).toList(),

            // Margin bawah pengganti SizedBox
            Container(
              margin: const EdgeInsets.only(bottom: 40),
            ),
          ],
        ),
      ),
    );
  }
}