import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:userapp/api/api_client.dart';
import 'package:userapp/models/appointment_models.dart';

class AppointmentApi {
  final Dio _dio;

  AppointmentApi(this._dio);

  Future<List<PointCollecteModel>> getPointsCollecte() async {
    final response = await _dio.get('/points-collecte');
    final data = response.data as List;
    return data
        .map((e) => PointCollecteModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<PointCollecteModel> getPointCollecteById(int id) async {
    final response = await _dio.get('/points-collecte/$id');
    return PointCollecteModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<List<JourDisponibleModel>> getJoursDisponibles({
    required int pointCollecteId,
    required int typeDonId,
    required int year,
    required int month,
  }) async {
    final response = await _dio.get(
      '/creneaux/jours-disponibles',
      queryParameters: {
        'pointCollecteId': pointCollecteId,
        'typeDonId': typeDonId,
        'year': year,
        'month': month,
      },
    );

    final data = response.data as List;
    return data
        .map((e) => JourDisponibleModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<CreneauCollecteModel>> getCreneauxDuJour({
    required int pointCollecteId,
    required int typeDonId,
    required String date,
  }) async {
    final response = await _dio.get(
      '/creneaux',
      queryParameters: {
        'pointCollecteId': pointCollecteId,
        'typeDonId': typeDonId,
        'date': date,
      },
    );

    final data = response.data as List;
    return data
        .map((e) => CreneauCollecteModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<QuestionnaireModel> getQuestionnaireEligibilite() async {
    final response = await _dio.get('/questionnaires');
    final data = response.data as List;

    final all = data
        .map((e) => QuestionnaireModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final questionnaire = all.cast<QuestionnaireModel?>().firstWhere(
          (q) => q != null && q.type == 'ELIGIBILITE_DONNEUR' && q.actif,
          orElse: () => null,
        );

    if (questionnaire == null) {
      throw Exception("Aucun questionnaire d'éligibilité actif trouvé");
    }

    return questionnaire;
  }

  Future<UserQuestionnaireResponseModel> soumettreQuestionnaire({
    required int userId,
    required int questionnaireId,
    required List<Map<String, dynamic>> reponses,
  }) async {
    final response = await _dio.post(
      '/questionnaires/soumettre',
      data: {
        'userId': userId,
        'questionnaireId': questionnaireId,
        'reponses': reponses,
      },
    );

    return UserQuestionnaireResponseModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<RendezVousModel> creerRendezVous({
    required int userId,
    required int pointCollecteId,
    required DateTime dateHeure,
  }) async {
    final response = await _dio.post(
      '/rendez-vous',
      data: {
        'userId': userId,
        'pointCollecteId': pointCollecteId,
        'dateHeure': dateHeure.toIso8601String(),
      },
    );

    return RendezVousModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<List<RendezVousModel>> getRendezVousUser(int userId) async {
    final response = await _dio.get('/rendez-vous/user/$userId');
    final data = response.data as List;

    return data
        .map((e) => RendezVousModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}

final appointmentApiProvider = Provider<AppointmentApi>((ref) {
  return AppointmentApi(ref.read(dioProvider));
});