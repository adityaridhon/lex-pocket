import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/pasal_controller.dart';
import '../models/pasal_model.dart';
import '../widgets/card_pasal.dart';

class PasalScreen extends StatefulWidget {
  const PasalScreen({super.key});

  @override
  State createState() => _PasalScreenState();
}

class _PasalScreenState extends State {
  final PasalController _pasalController = PasalController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List _listPasal = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _selectedType = '';

  static const List _typeFilters = [
    {'label': 'Semua', 'value': ''},
    {'label': 'UU', 'value': 'uu'},
    {'label': 'PP', 'value': 'pp'},
    {'label': 'PERPRES', 'value': 'perpres'},
    {'label': 'PERPPU', 'value': 'perppu'},
    {'label': 'UUD 1945', 'value': 'uud'},
    {'label': 'Putusan MK', 'value': 'putusan_mk'},
    {'label': 'PERMEN', 'value': 'permen'},
  ];

  @override
  void initState() {
    super.initState();
    _loadPasalData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future _loadPasalData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final String query = _searchController.text.trim();

    try {
      final List data = query.isNotEmpty
          ? await _pasalController.searchLaws(
        query: query,
        limit: 15,
        type: _selectedType,
      )
          : await _pasalController.fetchLaws(
        limit: 15,
        offset: 0,
        type: _selectedType,
      );

      if (!mounted) return;
      setState(() {
        _listPasal = data;
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

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadPasalData();
    });
  }

  void _onSearchSubmitted(String value) {
    _debounce?.cancel();
    _loadPasalData();
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    _loadPasalData();
  }

  void _onSelectType(String typeValue) {
    if (_selectedType == typeValue) return;
    setState(() {
      _selectedType = typeValue;
    });
    _loadPasalData();
  }

  @override
  Widget build(BuildContext context) {
    double landscapeHori =
        MediaQuery.of(context).padding.left + MediaQuery.of(context).padding.right;
    double lebarLayar = MediaQuery.of(context).size.width - landscapeHori;
    double x = 18;
    double lebarTengah = lebarLayar - (2 * x);

    final bool isSearching = _searchController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: _loadPasalData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // --- HEADER & SEARCH BAR ---
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF006199),
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          child: const Text(
                            'Selamat datang,',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Aditya Ridho',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: const Icon(
                              Icons.search,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              textInputAction: TextInputAction.search,
                              onChanged: _onSearchChanged,
                              onSubmitted: _onSearchSubmitted,
                              decoration: const InputDecoration(
                                hintText: 'Cari nomor, tahun, atau judul...',
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: _clearSearch,
                              child: Container(
                                padding: const EdgeInsets.only(left: 8),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- FILTER TIPE PERATURAN ---
              Container(
                margin: const EdgeInsets.only(bottom: 18),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: x),
                  child: Row(
                    children: [
                      for (final filter in _typeFilters)
                        GestureDetector(
                          onTap: () => _onSelectType(filter['value'].toString()),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedType == filter['value'].toString()
                                  ? const Color(0xFF006199)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _selectedType == filter['value'].toString()
                                    ? const Color(0xFF006199)
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              filter['label'].toString(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _selectedType == filter['value'].toString()
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // --- JUDUL SECTION ---
              Container(
                margin: EdgeInsets.only(left: x, right: x, bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: lebarTengah,
                      child: Text(
                        isSearching
                            ? 'Hasil Pencarian (${_listPasal.length})'
                            : 'Peraturan Terbaru',
                        style: const TextStyle(
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
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              else if (_listPasal.isEmpty)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 40, horizontal: x),
                    child: const Center(
                      child: Text(
                        'Tidak ada peraturan yang ditemukan.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  for (final PasalModel pasal in _listPasal)
                    CardPasal(
                      jenis: pasal.type,
                      nomor: pasal.number,
                      tahun: pasal.year,
                      status: pasal.status,
                      judul: pasal.title,
                      cuplikan: pasal.snippet,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/detail_pasal',
                          arguments: {
                            'type': pasal.type,
                            'raw_type': pasal.rawType,
                            'number': pasal.number,
                            'year': pasal.year,
                            'status': pasal.status,
                            'title': pasal.title,
                            'frbr_uri': pasal.frbrUri,
                            'url': pasal.url,
                            'isi_lengkap':
                            'Teks resmi dapat diakses melalui portal pasal.id.',
                          },
                        );
                      },
                    ),

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