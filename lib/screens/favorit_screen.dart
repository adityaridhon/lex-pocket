import 'package:flutter/material.dart';
import '../controllers/favorit_controller.dart';
import '../models/favorit_model.dart';
import '../widgets/card_favorit.dart';

class FavoritScreen extends StatefulWidget {
  const FavoritScreen({super.key});

  @override
  State<FavoritScreen> createState() => _FavoritScreenState();
}

class _FavoritScreenState extends State<FavoritScreen> {
  final FavoritController _favoritController = FavoritController();

  List<FavoritModel> _dataFavorit = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadFavorit();
  }

  Future<void> _loadFavorit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final List<FavoritModel> data = await _favoritController.fetchBookmarks();
      if (!mounted) return;
      setState(() {
        _dataFavorit = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _tampilkanPesan(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _hapusFavorit(int index) async {
    final FavoritModel favorit = _dataFavorit[index];
    final int? id = favorit.id;
    if (id == null) return;

    final bool? yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Favorit'),
          content: Text('Hapus "${favorit.judul}" dari daftar favorit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (yakin != true) return;

    try {
      await _favoritController.deleteBookmark(id);
      if (!mounted) return;
      setState(() {
        _dataFavorit.removeWhere((item) => item.id == id);
      });
      _tampilkanPesan('Favorit berhasil dihapus');
    } catch (e) {
      _tampilkanPesan('Gagal menghapus favorit: $e');
    }
  }

  Future<void> _editCatatan(int index) async {
    final FavoritModel favorit = _dataFavorit[index];
    final int? id = favorit.id;
    if (id == null) return;

    final TextEditingController editController =
        TextEditingController(text: favorit.catatanStudi);
    String catatanBaru = favorit.catatanStudi;
    String pesanError = '';

    final bool? disimpan = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return AlertDialog(
              title: const Text('Edit Catatan'),
              content: TextField(
                controller: editController,
                maxLength: FavoritModel.maxCatatan,
                maxLines: 3,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  errorText: pesanError.isEmpty ? null : pesanError,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final String catatan = editController.text.trim();

                    if (catatan.length < FavoritModel.minCatatan) {
                      setStateDialog(() {
                        pesanError =
                            'Catatan minimal ${FavoritModel.minCatatan} karakter.';
                      });
                      return;
                    }

                    if (catatan.length > FavoritModel.maxCatatan) {
                      setStateDialog(() {
                        pesanError =
                            'Catatan maksimal ${FavoritModel.maxCatatan} karakter.';
                      });
                      return;
                    }

                    catatanBaru = catatan;
                    Navigator.pop(dialogContext, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006199),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (disimpan != true) return;

    try {
      await _favoritController.updateCatatan(id, catatanBaru);
      if (!mounted) return;
      _tampilkanPesan('Catatan berhasil diperbarui');
      _loadFavorit();
    } catch (e) {
      _tampilkanPesan('Gagal memperbarui catatan: $e');
    }
  }

  Future<void> _bukaDetail(FavoritModel favorit) async {
    String url = '';
    if (favorit.frbrUri.startsWith('/')) {
      url = 'https://pasal.id${favorit.frbrUri}';
    } else if (favorit.frbrUri.startsWith('http')) {
      url = favorit.frbrUri;
    }

    await Navigator.pushNamed(
      context,
      '/detail_pasal',
      arguments: {
        'type': favorit.jenis,
        'number': favorit.nomor,
        'year': favorit.tahun,
        'status': 'Berlaku',
        'title': favorit.judul,
        'frbr_uri': favorit.frbrUri,
        'url': url,
      },
    );

    _loadFavorit();
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
      body: RefreshIndicator(
        onRefresh: _loadFavorit,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // --- HEADER CONTAINER (SAMAKAN DENGAN PASAL & PROFIL) ---
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(
                  top: 50,
                  left: 20,
                  right: 20,
                  bottom: 24,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF006199),
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Text(
                      'Pasal Favorit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- STATE: LOADING / ERROR / EMPTY / DATA ---
              if (_isLoading)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 40),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_errorMessage.isNotEmpty)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 40, horizontal: x),
                  child: Center(
                    child: Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              else if (_dataFavorit.isEmpty)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 40, horizontal: x),
                  child: const Center(
                    child: Text(
                      'Belum ada pasal favorit. Simpan pasal dari halaman detail.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                for (int index = 0; index < _dataFavorit.length; index++)
                  CardFavorit(
                    jenis: _dataFavorit[index].jenis,
                    nomor: _dataFavorit[index].nomor,
                    tahun: _dataFavorit[index].tahun,
                    status: 'Berlaku',
                    judul: _dataFavorit[index].judul,
                    cuplikan: _dataFavorit[index].frbrUri,
                    catatan: _dataFavorit[index].catatanStudi,
                    onTap: () => _bukaDetail(_dataFavorit[index]),
                    onEdit: () => _editCatatan(index),
                    onDelete: () => _hapusFavorit(index),
                  ),

              // Margin Bawah Pengganti SizedBox
              Container(
                margin: const EdgeInsets.only(bottom: 40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
