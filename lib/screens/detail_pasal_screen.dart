import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/favorit_controller.dart';
import '../helpers/auth_session.dart';
import '../models/favorit_model.dart';

class DetailPasalScreen extends StatefulWidget {
  const DetailPasalScreen({super.key});

  @override
  State createState() => _DetailPasalScreenState();
}

class _DetailPasalScreenState extends State {
  static const int _minCatatan = FavoritModel.minCatatan;
  static const int _maxCatatan = FavoritModel.maxCatatan;

  final FavoritController _favoritController = FavoritController();
  bool _isFavorited = false;
  bool _sedangProses = false;
  bool _sudahCekBookmark = false;
  int? _bookmarkId;
  final TextEditingController _catatanController = TextEditingController();

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'berlaku' || s == 'tetap') return Colors.green;
    if (s == 'diubah') return Colors.orange;
    if (s == 'dicabut') return Colors.red;
    return Colors.grey;
  }

  String _resolvePasalUrl(Map? args) {
    final String rawUrl = (args?['url'] ?? '').toString().trim();
    if (rawUrl.isNotEmpty) return rawUrl;

    final String frbrUri = (args?['frbr_uri'] ?? '').toString().trim();
    if (frbrUri.startsWith('/')) {
      return 'https://pasal.id$frbrUri';
    }

    return 'https://pasal.id';
  }

  String _resolveFrbrUri(Map? args) {
    final String frbrUri = (args?['frbr_uri'] ?? '').toString().trim();
    if (frbrUri.isNotEmpty) return frbrUri;

    final String url = (args?['url'] ?? '').toString().trim();
    if (url.isNotEmpty) return url;

    final String rawType =
        (args?['raw_type'] ?? args?['type'] ?? '-').toString();
    final String year = (args?['year'] ?? '-').toString();
    final String number = (args?['number'] ?? '-').toString();
    return '$rawType/$year/$number';
  }

  String _resolveNamaDokumen(Map? args) {
    final String jenis = (args?['type'] ?? '-').toString();
    final String nomor = (args?['number'] ?? '-').toString();
    final String tahun = (args?['year'] ?? '-').toString();
    final String judul = (args?['title'] ?? 'Tanpa Judul').toString();
    return '[$jenis] $nomor/$tahun - $judul';
  }

  Future _bukaUrlResmi(String urlString) async {
    final Uri? uri = Uri.tryParse(urlString);
    if (uri == null) {
      _tampilkanPesan('Format tautan tidak valid.');
      return;
    }

    final bool berhasil = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!berhasil && mounted) {
      _tampilkanPesan('Tidak dapat membuka browser untuk tautan ini.');
    }
  }

  void _salinUrl(String urlString) {
    Clipboard.setData(ClipboardData(text: urlString));
    _tampilkanPesan('Tautan pasal.id berhasil disalin');
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sudahCekBookmark) return;
    _sudahCekBookmark = true;
    _cekBookmarkTersimpan();
  }

  Future<void> _cekBookmarkTersimpan() async {
    if (!AuthSession.isLoggedIn) return;

    final args = ModalRoute.of(context)?.settings.arguments as Map?;

    try {
      final FavoritModel? favorit =
          await _favoritController.getBookmarkByUri(_resolveFrbrUri(args));
      if (favorit == null || !mounted) return;

      setState(() {
        _isFavorited = true;
        _bookmarkId = favorit.id;
        _catatanController.text = favorit.catatanStudi;
      });
    } catch (_) {
      // Status favorit opsional, kegagalan jaringan tidak menghalangi halaman.
    }
  }

  Future<void> _bukaDialogFavorit() async {
    if (_sedangProses) return;

    if (!AuthSession.isLoggedIn) {
      _tampilkanPesan('Silakan login untuk menyimpan favorit.');
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final String frbrUri = _resolveFrbrUri(args);
    final String namaDokumen = _resolveNamaDokumen(args);

    if (_isFavorited) {
      final int? id = _bookmarkId;
      if (id == null) return;

      setState(() {
        _sedangProses = true;
      });

      try {
        await _favoritController.deleteBookmark(id);
        if (!mounted) return;

        setState(() {
          _isFavorited = false;
          _bookmarkId = null;
          _catatanController.clear();
        });
        _tampilkanPesan('Pasal dihapus dari daftar favorit');
      } catch (e) {
        _tampilkanPesan('Gagal menghapus favorit: $e');
      } finally {
        if (mounted) {
          setState(() {
            _sedangProses = false;
          });
        }
      }
      return;
    }

    String pesanError = '';

    final bool? disimpan = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return AlertDialog(
              title: const Text('Simpan ke Favorit'),
              content: TextField(
                controller: _catatanController,
                maxLength: _maxCatatan,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tulis catatan pasal (minimal $_minCatatan karakter)...',
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
                    final String catatan = _catatanController.text.trim();

                    if (catatan.length < _minCatatan) {
                      setStateDialog(() {
                        pesanError =
                            'Catatan minimal $_minCatatan karakter.';
                      });
                      return;
                    }

                    if (catatan.length > _maxCatatan) {
                      setStateDialog(() {
                        pesanError =
                            'Catatan maksimal $_maxCatatan karakter.';
                      });
                      return;
                    }

                    _catatanController.text = catatan;
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

    if (disimpan != true || !mounted) return;

    setState(() {
      _sedangProses = true;
    });

    try {
      final FavoritModel favorit = await _favoritController.addBookmark(
        frbrUri: frbrUri,
        namaDokumen: namaDokumen,
        catatanStudi: _catatanController.text,
      );
      if (!mounted) return;

      setState(() {
        _isFavorited = true;
        _bookmarkId = favorit.id;
      });
      _tampilkanPesan('Pasal disimpan ke favorit');
    } catch (e) {
      _tampilkanPesan('Gagal menyimpan favorit: $e');
    } finally {
      if (mounted) {
        setState(() {
          _sedangProses = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;

    final String jenis = (args?['type'] ?? 'Undef').toString();
    final String nomor = (args?['number'] ?? '-').toString();
    final String tahun = (args?['year'] ?? '-').toString();
    final String status = (args?['status'] ?? '-').toString();
    final String judul = (args?['title'] ?? 'Judul Tidak Tersedia').toString();
    final String isiLengkap = (args?['isi_lengkap'] ??
        'Naskah lengkap peraturan tersedia melalui portal resmi pasal.id.')
        .toString();
    final String pasalUrl = _resolvePasalUrl(args);

    Color statusColor = _getStatusColor(status);

    double landscapeHori =
        MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right;
    double lebarLayar = MediaQuery.of(context).size.width - landscapeHori;
    double x = 24.0;
    double lebarTengah = lebarLayar - (2 * x);
    double lebarTengahAppBar = lebarTengah - 48;
    double lebarDalamUrlCard = lebarTengah - 30;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // --- TOP BAR ---
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: Row(
                        children: [
                          Container(width: x),
                          Container(
                            width: lebarTengah,
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    width: 24,
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Container(
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
                                GestureDetector(
                                  onTap: _bukaDialogFavorit,
                                  child: Container(
                                    width: 24,
                                    child: Icon(
                                      _isFavorited
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: _isFavorited
                                          ? const Color(0xFF006199)
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(width: x),
                        ],
                      ),
                    ),

                    // --- METADATA BADGE ---
                    Container(
                      margin: const EdgeInsets.only(top: 32),
                      child: Row(
                        children: [
                          Container(width: x),
                          Container(
                            width: lebarTengah,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade400),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      jenis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(width: 10),
                                  Text(
                                    '$nomor/$tahun',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      border: Border.all(
                                        color: statusColor.withOpacity(0.5),
                                      ),
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
                            ),
                          ),
                          Container(width: x),
                        ],
                      ),
                    ),

                    // --- JUDUL PERATURAN ---
                    Container(
                      margin: const EdgeInsets.only(top: 24),
                      child: Row(
                        children: [
                          Container(width: x),
                          Container(
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
                          Container(width: x),
                        ],
                      ),
                    ),

                    // --- DIVIDER ---
                    Container(
                      margin: const EdgeInsets.only(top: 24),
                      child: Row(
                        children: [
                          Container(width: x),
                          Container(
                            width: lebarTengah,
                            height: 1,
                            color: Colors.grey.shade200,
                          ),
                          Container(width: x),
                        ],
                      ),
                    ),

                    // --- RINGKASAN / KETERANGAN ---
                    Container(
                      margin: const EdgeInsets.only(top: 24),
                      child: Row(
                        children: [
                          Container(width: x),
                          Container(
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
                          Container(width: x),
                        ],
                      ),
                    ),

                    // --- KARTU TAUTAN RESMI PASAL.ID ---
                    Container(
                      margin: const EdgeInsets.only(top: 24, bottom: 40),
                      child: Row(
                        children: [
                          Container(width: x),
                          Container(
                            width: lebarTengah,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F8FB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFD0E3F0),
                              ),
                            ),
                            child: Column(
                              children: [
                                // Baris label & tombol salin
                                Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      margin: const EdgeInsets.only(right: 8),
                                      child: const Icon(
                                        Icons.language,
                                        size: 18,
                                        color: Color(0xFF006199),
                                      ),
                                    ),
                                    Container(
                                      width: lebarDalamUrlCard - 52,
                                      child: const Text(
                                        'Sumber Dokumen Resmi',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _salinUrl(pasalUrl),
                                      child: Container(
                                        width: 24,
                                        child: const Icon(
                                          Icons.copy_rounded,
                                          size: 18,
                                          color: Color(0xFF006199),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Baris URL bersih (bisa diketuk untuk membuka browser)
                                GestureDetector(
                                  onTap: () => _bukaUrlResmi(pasalUrl),
                                  child: Container(
                                    width: lebarDalamUrlCard,
                                    margin: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      pasalUrl,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF006199),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),

                                // Tombol buka browser
                                GestureDetector(
                                  onTap: () => _bukaUrlResmi(pasalUrl),
                                  child: Container(
                                    width: lebarDalamUrlCard,
                                    margin: const EdgeInsets.only(top: 12),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFF006199),
                                      ),
                                    ),
                                    child: const Text(
                                      'Buka Naskah Lengkap di pasal.id',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF006199),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(width: x),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- BOTTOM STICKY BAR (FAVORIT) ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(width: x),
                  GestureDetector(
                    onTap: _bukaDialogFavorit,
                    child: Container(
                      width: lebarTengah,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _isFavorited
                            ? Colors.white
                            : const Color(0xFF006199),
                        border: Border.all(
                          color: _isFavorited
                              ? Colors.red
                              : const Color(0xFF006199),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isFavorited
                            ? 'Hapus dari Favorit'
                            : 'Simpan ke Favorit',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _isFavorited ? Colors.red : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(width: x),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}