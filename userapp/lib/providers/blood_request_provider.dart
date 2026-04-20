import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:userapp/api/api_client.dart';
import 'package:userapp/api/blood_request_api.dart';
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
        raisonDemande: body.raisonDemande ?? '',
        notesComplementaires: body.notesComplementaires ?? '',
        userId: body.userId,
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