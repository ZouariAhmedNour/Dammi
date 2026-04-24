class DonorCard {
  final int id;
  final String groupeSanguin;
  final int nbDon;
  final DateTime? dateEditionCarte;
  final String? lieuCollecte;

  DonorCard({
    required this.id,
    required this.groupeSanguin,
    required this.nbDon,
    required this.dateEditionCarte,
    required this.lieuCollecte,
  });

  factory DonorCard.fromJson(Map<String, dynamic> json) {
    return DonorCard(
      id: json['id'] as int,
      groupeSanguin: json['groupeSanguin'] ?? '',
      nbDon: (json['nbDon'] ?? 0) as int,
      dateEditionCarte: json['dateEditionCarte'] != null
          ? DateTime.tryParse(json['dateEditionCarte'])
          : null,
      lieuCollecte: json['lieuCollecte'],
    );
  }
}