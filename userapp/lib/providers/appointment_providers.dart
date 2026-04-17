import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateNotifierProvider;
import 'package:state_notifier/state_notifier.dart';
import 'package:userapp/api/appointment_api.dart';
import 'package:userapp/models/appointment_models.dart';
import 'package:userapp/providers/auth_provider.dart';

final pointsCollecteProvider = FutureProvider<List<PointCollecteModel>>((ref) async {
  return ref.read(appointmentApiProvider).getPointsCollecte();
});

final pointCollecteDetailsProvider =
    FutureProvider.family<PointCollecteModel, int>((ref, pointId) async {
  return ref.read(appointmentApiProvider).getPointCollecteById(pointId);
});

typedef AvailableDaysArgs = ({int pointCollecteId, int typeDonId, int year, int month});
typedef DaySlotsArgs = ({int pointCollecteId, int typeDonId, String date});

final joursDisponiblesProvider =
    FutureProvider.family<List<JourDisponibleModel>, AvailableDaysArgs>((ref, args) async {
  return ref.read(appointmentApiProvider).getJoursDisponibles(
        pointCollecteId: args.pointCollecteId,
        typeDonId: args.typeDonId,
        year: args.year,
        month: args.month,
      );
});

final creneauxDuJourProvider =
    FutureProvider.family<List<CreneauCollecteModel>, DaySlotsArgs>((ref, args) async {
  return ref.read(appointmentApiProvider).getCreneauxDuJour(
        pointCollecteId: args.pointCollecteId,
        typeDonId: args.typeDonId,
        date: args.date,
      );
});

final questionnaireEligibiliteProvider = FutureProvider<QuestionnaireModel>((ref) async {
  return ref.read(appointmentApiProvider).getQuestionnaireEligibilite();
});

class AppointmentFlowNotifier extends StateNotifier<AppointmentFlowState> {
  AppointmentFlowNotifier() : super(AppointmentFlowState.empty);

  void setSelection({
    required PointCollecteModel point,
    required TypeDonLite typeDon,
    required DateTime date,
    required CreneauCollecteModel slot,
  }) {
    state = AppointmentFlowState(
      pointCollecteId: point.id,
      pointCollecteNom: point.nom,
      typeDon: typeDon,
      selectedDate: DateTime(date.year, date.month, date.day),
      selectedSlot: slot,
    );
  }

  void reset() {
    state = AppointmentFlowState.empty;
  }
}

final appointmentFlowProvider =
    StateNotifierProvider<AppointmentFlowNotifier, AppointmentFlowState>((ref) {
  return AppointmentFlowNotifier();
});

final rendezVousHistoryProvider = FutureProvider<List<RendezVousModel>>((ref) async {
  final auth = ref.watch(authControllerProvider);
  final userId = auth.user?.id;

  if (userId == null) {
    return [];
  }

  return ref.read(appointmentApiProvider).getRendezVousUser(userId);
});