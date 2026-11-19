class PasalModel {
  final String rawType;
  final String type;
  final String number;
  final String year;
  final String status;
  final String title;
  final String frbrUri;
  final String url;
  final String snippet;

  PasalModel({
    required this.rawType,
    required this.type,
    required this.number,
    required this.year,
    required this.status,
    required this.title,
    required this.frbrUri,
    required this.url,
    required this.snippet,
  });

  factory PasalModel.fromJson(Map rawJson) {
    final Map json = Map.from(rawJson);

    // Ekstrak field dari sub-object 'work' (hasil /api/v1/search)
    for (final nestedKey in ['work', 'law', 'document', 'regulation', 'metadata']) {
      if (json[nestedKey] is Map) {
        final Map nested = Map.from(json[nestedKey]);
        nested.forEach((key, value) {
          json.putIfAbsent(key, () => value);
        });
      }
    }

    final String rawTypeValue =
    (json['type'] ?? json['law_type'] ?? json['jenis'] ?? '').toString();

    final String numberValue =
    (json['number'] ?? json['law_number'] ?? json['nomor'] ?? '-')
        .toString();

    final String yearValue =
    (json['year'] ?? json['law_year'] ?? json['tahun'] ?? '-').toString();

    final String statusValue =
    (json['status'] ?? json['law_status'] ?? 'Berlaku').toString();

    final String titleValue = (json['title'] ??
        json['law_title'] ??
        json['judul'] ??
        json['name'] ??
        'Tanpa Judul')
        .toString();

    final String frbrUriValue =
    (json['frbr_uri'] ?? json['law_frbr_uri'] ?? '').toString();

    String urlValue =
    (json['url'] ?? json['law_url'] ?? json['link'] ?? '').toString();
    if (urlValue.isEmpty && frbrUriValue.startsWith('/')) {
      urlValue = 'https://pasal.id$frbrUriValue';
    }

    return PasalModel(
      rawType: rawTypeValue,
      type: parseType(rawTypeValue),
      number: numberValue.isNotEmpty ? numberValue : '-',
      year: yearValue.isNotEmpty ? yearValue : '-',
      status: statusValue.isNotEmpty ? statusValue : 'Berlaku',
      title: titleValue.isNotEmpty ? titleValue : 'Tanpa Judul',
      frbrUri: frbrUriValue,
      url: urlValue,
      snippet: _extractSnippet(json),
    );
  }

  static String _extractSnippet(Map json) {
    // 1. Cek best_passage dari /api/v1/search
    final dynamic bestPassage = json['best_passage'];
    if (bestPassage is String && bestPassage.trim().isNotEmpty) {
      return bestPassage.replaceAll(RegExp(r'\s+'), ' ').trim();
    } else if (bestPassage is Map) {
      final String pasalNum = (bestPassage['pasal'] ?? '').toString().trim();
      final String passageText = (bestPassage['text'] ??
          bestPassage['content'] ??
          bestPassage['passage'] ??
          bestPassage['snippet'] ??
          '')
          .toString()
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      if (pasalNum.isNotEmpty && passageText.isNotEmpty) {
        return 'Pasal $pasalNum: $passageText';
      } else if (passageText.isNotEmpty) {
        return passageText;
      }
    }

    // 2. Cek snippet / excerpt standar
    final String rawSnippet = (json['snippet'] ??
        json['excerpt'] ??
        json['highlight'] ??
        json['content'] ??
        json['text'] ??
        '')
        .toString()
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (rawSnippet.isNotEmpty) {
      return rawSnippet;
    }

    // 3. Cek daftar matching_pasals dari /api/v1/search
    if (json['matching_pasals'] is List) {
      final List matches = json['matching_pasals'];
      final List pasalLabels = [
        for (final item in matches)
          if (item is Map && item['pasal'] != null) 'Pasal ${item['pasal']}'
      ];
      if (pasalLabels.isNotEmpty) {
        return 'Ditemukan pada ${pasalLabels.join(', ')}';
      }
    }

    return 'Klik untuk melihat metadata dan tautan pasal resmi...';
  }

  static String parseType(String rawType) {
    if (rawType.trim().isEmpty) return '-';

    const Map typeLabels = {
      'uud': 'UUD 1945',
      'uud_1945': 'UUD 1945',
      'tap_mpr': 'TAP MPR',
      'uu': 'UU',
      'perppu': 'PERPPU',
      'pp': 'PP',
      'perpres': 'PERPRES',
      'permen': 'PERMEN',
      'perda': 'PERDA',
      'perbup': 'PERBUP',
      'pergub': 'PERGUB',
      'perwali': 'PERWALI',
      'keppres': 'KEPPRES',
      'inpres': 'INPRES',
      'putusan_mk': 'Putusan MK',
      'putusan_ma': 'Putusan MA',
    };

    final String normalized = rawType.trim().toLowerCase();
    if (typeLabels.containsKey(normalized)) {
      return typeLabels[normalized].toString();
    }

    if (normalized.startsWith('putusan_')) {
      final String suffix = normalized.replaceFirst('putusan_', '').toUpperCase();
      return 'Putusan $suffix';
    }

    return normalized.replaceAll('_', ' ').toUpperCase();
  }
}