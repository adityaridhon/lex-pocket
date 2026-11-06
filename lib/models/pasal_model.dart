class PasalModel {
  final int? id;
  final String frbrUri;
  final String title;
  final String number;
  final String year;
  final String status;
  final String type;
  final String? url;

  PasalModel({
    this.id,
    required this.frbrUri,
    required this.title,
    required this.number,
    required this.year,
    required this.status,
    required this.type,
    this.url,
  });

  factory PasalModel.fromJson(Map<String, dynamic> json) {
    return PasalModel(
      id: json['id'],
      frbrUri: json['frbr_uri'] ?? '',
      title: json['title'] ?? 'Judul Tidak Tersedia',
      number: json['number']?.toString() ?? '-',
      year: json['year']?.toString() ?? '-',
      status: json['status'] ?? 'berlaku',
      type: json['type'] ?? 'UU',
      url: json['url'],
    );
  }
}