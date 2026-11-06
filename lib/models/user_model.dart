class UserModel {
  final String id;
  final String nama;
  final String email;
  final String? tanggalDaftar;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    this.tanggalDaftar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      tanggalDaftar: json['tanggal_daftar'],
    );
  }
}