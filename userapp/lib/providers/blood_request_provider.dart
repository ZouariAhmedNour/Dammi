import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:userapp/api/api_client.dart';
import 'package:userapp/api/appointment_api.dart';
import 'package:userapp/api/blood_request_api.dart';
import 'package:userapp/models/appointment_models.dart';
import 'package:userapp/models/blood_request.dart';

final bloodRequestApiProvider = Provider<BloodRequestApi>((ref) {
  return BloodRequestApi(ref.read(dioProvider));
});

final userBloodRequestsProvider =
    FutureProvider.family<List<BloodRequest>, int>((ref, userId) async {
  return ref.read(bloodRequestApiProvider).getUserRequests(userId);
});

final bloodRequestSubmitProvider =
    StateNotifierProvider<BloodRequestSubmitNotifier, AsyncValue<void>>((ref) {
  return BloodRequestSubmitNotifier(ref.read(bloodRequestApiProvider));
});

final pointsCollecteProvider = FutureProvider<List<PointCollecteModel>>((ref) async {
  return ref.read(appointmentApiProvider).getPointsCollecte();
});

final allRequestsProvider =
    FutureProvider<List<BloodRequest>>((ref) async {
  return ref.read(bloodRequestApiProvider).getAllRequests();
});

class BloodRequestSubmitNotifier extends StateNotifier<AsyncValue<void>> {
  final BloodRequestApi _api;

  BloodRequestSubmitNotifier(this._api) : super(const AsyncData(null));

  Future<BloodRequest> submit(BloodRequestCreateBody body) async {
    state = const AsyncLoading();
    try {
      final result = await _api.createRequest(
        quantite: body.quantite,
        urgence: body.urgence,
        contactNom: body.contactNom,
        contactTelephone: body.contactTelephone,
        raisonDemande: body.raisonDemande ?? '',
        notesComplementaires: body.notesComplementaires ?? '',
        userId: body.userId,
        pointCollecteId: body.pointCollecteId,
        typeSanguinId: body.typeSanguinId ?? 0,
      );
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}