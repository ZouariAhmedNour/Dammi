import 'dart:convert';

class User {
  final int? id;
  final String prenom;
  final String nom;
  final String email;
  final String? phone;
  final String? sexe;
  final String? avatar;
  final String? role;
  final String? eligibilityStatus;
  final bool? statutPertinent;
  final DateTime? lastDonation;
  final int? typeSanguinId;
  final String? typeSanguinAboGroup;

  const User({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.email,
    this.phone,
    this.sexe,
    this.avatar,
    this.role,
    this.eligibilityStatus,
    this.statutPertinent,
    this.lastDonation,
    this.typeSanguinId,
    this.typeSanguinAboGroup,
  });

  String get fullName {
    final name = '$prenom $nom'.trim();
    return name.isEmpty ? 'Utilisateur' : name;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _toInt(json['id']),
      prenom: (json['prenom'] ?? json['firstName'] ?? '').toString(),
      nom: (json['nom'] ?? json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      sexe: json['sexe']?.toString(),
      avatar: json['avatar']?.toString(),
      role: json['role']?.toString(),
      eligibilityStatus: json['eligibilityStatus']?.toString(),
      statutPertinent: _toBool(json['statutPertinent']),
      lastDonation: _parseDate(json['lastDonation']),
      typeSanguinId: _toInt(json['typeSanguinId']),
      typeSanguinAboGroup: json['typeSanguinAboGroup']?.toString(),
    );
  }

  factory User.fromRawJson(String source) =>
      User.fromJson(jsonDecode(source) as Map<String, dynamic>);

  String toRawJson() => jsonEncode(toJson());

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prenom': prenom,
      'nom': nom,
      'email': email,
      'phone': phone,
      'sexe': sexe,
      'avatar': avatar,
      'role': role,
      'eligibilityStatus': eligibilityStatus,
      'statutPertinent': statutPertinent,
      'lastDonation': lastDonation?.toIso8601String(),
      'typeSanguinId': typeSanguinId,
      'typeSanguinAboGroup': typeSanguinAboGroup,
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    final text = value.toString().toLowerCase();
    if (text == 'true') return true;
    if (text == 'false') return false;
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}