import 'package:flutter/foundation.dart';

class TypeDonLite {
  final int id;
  final String label;

  const TypeDonLite({
    required this.id,
    required this.label,
  });

  factory TypeDonLite.fromJson(Map<String, dynamic> json) {
    return TypeDonLite(
      id: _toInt(json['id']) ?? 0,
      label: (json['label'] ?? '').toString(),
    );
  }
}

class PointCollecteModel {
  final int id;
  final String nom;
  final String gouvernorat;
  final String delegation;
  final String codePostal;
  final String adressePostale;
  final int capacite;
  final String? telephone;
  final double latitude;
  final double longitude;
  final String? description;
  final List<TypeDonLite> typesDon;

  const PointCollecteModel({
    required this.id,
    required this.nom,
    required this.gouvernorat,
    required this.delegation,
    required this.codePostal,
    required this.adressePostale,
    required this.capacite,
    required this.telephone,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.typesDon,
  });

  String get fullAddress => '$adressePostale, $delegation, $gouvernorat';

  factory PointCollecteModel.fromJson(Map<String, dynamic> json) {
    final types = (json['typesDon'] as List?)
            ?.map((e) => TypeDonLite.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];

    return PointCollecteModel(
      id: _toInt(json['id']) ?? 0,
      nom: (json['nom'] ?? '').toString(),
      gouvernorat: (json['gouvernorat'] ?? '').toString(),
      delegation: (json['delegation'] ?? '').toString(),
      codePostal: (json['codePostal'] ?? '').toString(),
      adressePostale: (json['adressePostale'] ?? '').toString(),
      capacite: _toInt(json['capacite']) ?? 0,
      telephone: json['telephone']?.toString(),
      latitude: _toDouble(json['latitude']) ?? 0,
      longitude: _toDouble(json['longitude']) ?? 0,
      description: json['description']?.toString(),
      typesDon: types,
    );
  }
}

class JourDisponibleModel {
  final String date;
  final int nombreCreneaux;

  const JourDisponibleModel({
    required this.date,
    required this.nombreCreneaux,
  });

  DateTime get parsedDate => DateTime.parse(date);

  factory JourDisponibleModel.fromJson(Map<String, dynamic> json) {
    return JourDisponibleModel(
      date: (json['date'] ?? '').toString(),
      nombreCreneaux: _toInt(json['nombreCreneaux']) ?? 0,
    );
  }
}

class CreneauCollecteModel {
  final int id;
  final int pointCollecteId;
  final String pointCollecteNom;
  final int typeDonId;
  final String typeDonLabel;
  final String dateCollecte;
  final String heureDebut;
  final int placesTotales;
  final int placesRestantes;
  final bool actif;

  const CreneauCollecteModel({
    required this.id,
    required this.pointCollecteId,
    required this.pointCollecteNom,
    required this.typeDonId,
    required this.typeDonLabel,
    required this.dateCollecte,
    required this.heureDebut,
    required this.placesTotales,
    required this.placesRestantes,
    required this.actif,
  });

  DateTime get dateTime {
    final hour = heureDebut.length == 5 ? '$heureDebut:00' : heureDebut;
    return DateTime.parse('${dateCollecte}T$hour');
  }

  factory CreneauCollecteModel.fromJson(Map<String, dynamic> json) {
    return CreneauCollecteModel(
      id: _toInt(json['id']) ?? 0,
      pointCollecteId: _toInt(json['pointCollecteId']) ?? 0,
      pointCollecteNom: (json['pointCollecteNom'] ?? '').toString(),
      typeDonId: _toInt(json['typeDonId']) ?? 0,
      typeDonLabel: (json['typeDonLabel'] ?? '').toString(),
      dateCollecte: (json['dateCollecte'] ?? '').toString(),
      heureDebut: (json['heureDebut'] ?? '').toString(),
      placesTotales: _toInt(json['placesTotales']) ?? 0,
      placesRestantes: _toInt(json['placesRestantes']) ?? 0,
      actif: json['actif'] == true,
    );
  }
}

class QuestionOptionModel {
  final int id;
  final String label;
  final String value;
  final int ordre;
  final String niveauBlocage;
  final bool active;

  const QuestionOptionModel({
    required this.id,
    required this.label,
    required this.value,
    required this.ordre,
    required this.niveauBlocage,
    required this.active,
  });

  factory QuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return QuestionOptionModel(
      id: _toInt(json['id']) ?? 0,
      label: (json['label'] ?? '').toString(),
      value: (json['value'] ?? '').toString(),
      ordre: _toInt(json['ordre']) ?? 0,
      niveauBlocage: (json['niveauBlocage'] ?? 'NONE').toString(),
      active: json['active'] == true,
    );
  }
}

class QuestionModel {
  final int id;
  final String? code;
  final String texte;
  final String typeReponse;
  final String? aide;
  final String applicableSex;
  final double? minNumericValue;
  final double? maxNumericValue;
  final String outOfRangeBlockingLevel;
  final bool actif;
  final List<QuestionOptionModel> options;

  const QuestionModel({
    required this.id,
    required this.code,
    required this.texte,
    required this.typeReponse,
    required this.aide,
    required this.applicableSex,
    required this.minNumericValue,
    required this.maxNumericValue,
    required this.outOfRangeBlockingLevel,
    required this.actif,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List?)
            ?.map((e) => QuestionOptionModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];

    return QuestionModel(
      id: _toInt(json['id']) ?? 0,
      code: json['code']?.toString(),
      texte: (json['texte'] ?? '').toString(),
      typeReponse: (json['typeReponse'] ?? '').toString(),
      aide: json['aide']?.toString(),
      applicableSex: (json['applicableSex'] ?? 'ALL').toString(),
      minNumericValue: _toDouble(json['minNumericValue']),
      maxNumericValue: _toDouble(json['maxNumericValue']),
      outOfRangeBlockingLevel: (json['outOfRangeBlockingLevel'] ?? 'NONE').toString(),
      actif: json['actif'] == true,
      options: options,
    );
  }
}

class QuestionnaireQuestionModel {
  final int id;
  final int questionId;
  final int ordre;
  final bool obligatoire;
  final QuestionModel question;

  const QuestionnaireQuestionModel({
    required this.id,
    required this.questionId,
    required this.ordre,
    required this.obligatoire,
    required this.question,
  });

  factory QuestionnaireQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionnaireQuestionModel(
      id: _toInt(json['id']) ?? 0,
      questionId: _toInt(json['questionId']) ?? 0,
      ordre: _toInt(json['ordre']) ?? 0,
      obligatoire: json['obligatoire'] == true,
      question: QuestionModel.fromJson(
        Map<String, dynamic>.from(json['question'] as Map),
      ),
    );
  }
}

class QuestionnaireModel {
  final int id;
  final String titre;
  final String? description;
  final String type;
  final bool actif;
  final List<QuestionnaireQuestionModel> questions;

  const QuestionnaireModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.type,
    required this.actif,
    required this.questions,
  });

  factory QuestionnaireModel.fromJson(Map<String, dynamic> json) {
    final questions = (json['questions'] as List?)
            ?.map(
              (e) => QuestionnaireQuestionModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList() ??
        [];

    questions.sort((a, b) => a.ordre.compareTo(b.ordre));

    return QuestionnaireModel(
      id: _toInt(json['id']) ?? 0,
      titre: (json['titre'] ?? '').toString(),
      description: json['description']?.toString(),
      type: (json['type'] ?? '').toString(),
      actif: json['actif'] == true,
      questions: questions,
    );
  }
}

class UserQuestionnaireResponseModel {
  final int id;
  final int userId;
  final int questionnaireId;
  final String questionnaireTitre;
  final DateTime? dateSoumission;
  final String resultat;
  final String? motifResultat;

  const UserQuestionnaireResponseModel({
    required this.id,
    required this.userId,
    required this.questionnaireId,
    required this.questionnaireTitre,
    required this.dateSoumission,
    required this.resultat,
    required this.motifResultat,
  });

  bool get isEligible => resultat == 'ELIGIBLE';

  factory UserQuestionnaireResponseModel.fromJson(Map<String, dynamic> json) {
    return UserQuestionnaireResponseModel(
      id: _toInt(json['id']) ?? 0,
      userId: _toInt(json['userId']) ?? 0,
      questionnaireId: _toInt(json['questionnaireId']) ?? 0,
      questionnaireTitre: (json['questionnaireTitre'] ?? '').toString(),
      dateSoumission: json['dateSoumission'] != null
          ? DateTime.tryParse(json['dateSoumission'].toString())
          : null,
      resultat: (json['resultat'] ?? '').toString(),
      motifResultat: json['motifResultat']?.toString(),
    );
  }
}

class RendezVousModel {
  final int id;
  final DateTime? dateHeure;
  final String statut;
  final int? userId;
  final String? userNom;
  final String? pointCollecteNom;

  const RendezVousModel({
    required this.id,
    required this.dateHeure,
    required this.statut,
    required this.userId,
    required this.userNom,
    required this.pointCollecteNom,
  });

  factory RendezVousModel.fromJson(Map<String, dynamic> json) {
    return RendezVousModel(
      id: _toInt(json['id']) ?? 0,
      dateHeure: json['dateHeure'] != null
          ? DateTime.tryParse(json['dateHeure'].toString())
          : null,
      statut: (json['statut'] ?? '').toString(),
      userId: _toInt(json['userId']),
      userNom: json['userNom']?.toString(),
      pointCollecteNom: json['pointCollecteNom']?.toString(),
    );
  }
}

@immutable
class AppointmentFlowState {
  final int? pointCollecteId;
  final String? pointCollecteNom;
  final TypeDonLite? typeDon;
  final DateTime? selectedDate;
  final CreneauCollecteModel? selectedSlot;

  const AppointmentFlowState({
    this.pointCollecteId,
    this.pointCollecteNom,
    this.typeDon,
    this.selectedDate,
    this.selectedSlot,
  });

  AppointmentFlowState copyWith({
    int? pointCollecteId,
    String? pointCollecteNom,
    TypeDonLite? typeDon,
    DateTime? selectedDate,
    CreneauCollecteModel? selectedSlot,
    bool clearTypeDon = false,
    bool clearDate = false,
    bool clearSlot = false,
  }) {
    return AppointmentFlowState(
      pointCollecteId: pointCollecteId ?? this.pointCollecteId,
      pointCollecteNom: pointCollecteNom ?? this.pointCollecteNom,
      typeDon: clearTypeDon ? null : (typeDon ?? this.typeDon),
      selectedDate: clearDate ? null : (selectedDate ?? this.selectedDate),
      selectedSlot: clearSlot ? null : (selectedSlot ?? this.selectedSlot),
    );
  }

  static const empty = AppointmentFlowState();
}

@immutable
class AppointmentResultArgs {
  final bool success;
  final String title;
  final String message;
  final RendezVousModel? rendezVous;
  final String? motif;

  const AppointmentResultArgs({
    required this.success,
    required this.title,
    required this.message,
    this.rendezVous,
    this.motif,
  });
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}