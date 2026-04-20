enum BloodRequestStatus { enAttente, approuvee, refusee, annulee, satisfaite }

extension BloodRequestStatusX on BloodRequestStatus {
  static BloodRequestStatus fromJson(String? value) {
    switch (value) {
      case 'APPROUVEE':
        return BloodRequestStatus.approuvee;
      case 'REFUSEE':
        return BloodRequestStatus.refusee;
      case 'ANNULEE':
        return BloodRequestStatus.annulee;
      case 'SATISFAITE':
        return BloodRequestStatus.satisfaite;
      case 'EN_ATTENTE':
      default:
        return BloodRequestStatus.enAttente;
    }
  }

  String get apiValue {
    switch (this) {
      case BloodRequestStatus.approuvee:
        return 'APPROUVEE';
      case BloodRequestStatus.refusee:
        return 'REFUSEE';
      case BloodRequestStatus.annulee:
        return 'ANNULEE';
      case BloodRequestStatus.satisfaite:
        return 'SATISFAITE';
      case BloodRequestStatus.enAttente:
        return 'EN_ATTENTE';
    }
  }

  String get label {
    switch (this) {
      case BloodRequestStatus.approuvee:
        return 'APPROUVÉE';
      case BloodRequestStatus.refusee:
        return 'REFUSÉE';
      case BloodRequestStatus.annulee:
        return 'ANNULÉE';
      case BloodRequestStatus.satisfaite:
        return 'SATISFAITE';
      case BloodRequestStatus.enAttente:
        return 'EN ATTENTE';
    }
  }
}

class BloodRequest {
  final int id;
  final int quantite;
  final BloodRequestStatus statut;
  final DateTime? dateCreation;
  final bool urgence;
  final String contactNom;
  final String? raisonDemande;
  final String? notesComplementaires;
  final int userId;
  final String? userNom;
  final String? typeSanguinAboGroup;

  /// Optionnel: à renvoyer côté backend pour une vraie barre de progression.
  final int? quantiteLivree;

  const BloodRequest({
    required this.id,
    required this.quantite,
    required this.statut,
    required this.dateCreation,
    required this.urgence,
    required this.contactNom,
    required this.raisonDemande,
    required this.notesComplementaires,
    required this.userId,
    required this.userNom,
    required this.typeSanguinAboGroup,
    this.quantiteLivree,
  });

  factory BloodRequest.fromJson(Map<String, dynamic> json) {
    return BloodRequest(
      id: (json['id'] as num).toInt(),
      quantite: (json['quantite'] as num?)?.toInt() ?? 0,
      statut: BloodRequestStatusX.fromJson(json['statut'] as String?),
      dateCreation: json['dateCreation'] != null
          ? DateTime.tryParse(json['dateCreation'].toString())
          : null,
      urgence: json['urgence'] as bool? ?? false,
      contactNom: json['contactNom'] as String? ?? '',
      raisonDemande: json['raisonDemande'] as String?,
      notesComplementaires: json['notesComplementaires'] as String?,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      userNom: json['userNom'] as String?,
      typeSanguinAboGroup: json['typeSanguinAboGroup'] as String?,
      quantiteLivree: json['quantiteLivree'] != null
          ? (json['quantiteLivree'] as num).toInt()
          : null,
    );
  }

  double get progress {
    final delivered = quantiteLivree ??
        (statut == BloodRequestStatus.satisfaite ? quantite : 0);
    if (quantite <= 0) return 0;
    return (delivered / quantite).clamp(0.0, 1.0);
  }

  String get progressLabel {
    final delivered = quantiteLivree ??
        (statut == BloodRequestStatus.satisfaite ? quantite : 0);
    return '$delivered/$quantite poches';
  }
}

class BloodRequestCreateBody {
  final int quantite;
  final bool urgence;
  final String contactNom;
  final String? raisonDemande;
  final String? notesComplementaires;
  final int userId;
  final int? typeSanguinId;

  const BloodRequestCreateBody({
    required this.quantite,
    required this.urgence,
    required this.contactNom,
    required this.raisonDemande,
    required this.notesComplementaires,
    required this.userId,
    required this.typeSanguinId,
  });

  Map<String, dynamic> toJson() {
    return {
      'quantite': quantite,
      'urgence': urgence,
      'contactNom': contactNom,
      'raisonDemande': raisonDemande,
      'notesComplementaires': notesComplementaires,
      'userId': userId,
      'typeSanguinId': typeSanguinId,
    };
  }
}