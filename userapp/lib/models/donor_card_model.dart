class DonorCardModel {
  final int id;
  final String groupeSanguin;
  final int nbDon;
  final DateTime? dateEditionCarte;
  final String? lieuCollecte;

  const DonorCardModel({
    required this.id,
    required this.groupeSanguin,
    required this.nbDon,
    this.dateEditionCarte,
    this.lieuCollecte,
  });

  factory DonorCardModel.fromJson(Map<String, dynamic> json) {
    return DonorCardModel(
      id: json['id'] as int,
      groupeSanguin: (json['groupeSanguin'] ?? '').toString(),
      nbDon: (json['nbDon'] ?? 0) as int,
      dateEditionCarte: json['dateEditionCarte'] != null
          ? DateTime.tryParse(json['dateEditionCarte'].toString())
          : null,
      lieuCollecte: json['lieuCollecte']?.toString(),
    );
  }
}