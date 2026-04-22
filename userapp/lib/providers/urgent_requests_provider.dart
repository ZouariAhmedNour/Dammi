import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:userapp/api/api_client.dart';
import 'package:userapp/api/blood_request_api.dart';
import 'package:userapp/models/blood_request.dart';

final bloodRequestApiProvider = Provider<BloodRequestApi>((ref) {
  return BloodRequestApi(ref.read(dioProvider));
});

final urgentBloodRequestsProvider =
    FutureProvider<List<BloodRequest>>((ref) async {
  return ref.read(bloodRequestApiProvider).getUrgentRequests();
});

final urgentSeenStorageProvider = Provider<UrgentSeenStorage>((ref) {
  return UrgentSeenStorage();
});

final hasUnreadUrgentRequestsProvider =
    FutureProvider.family<bool, int>((ref, userId) async {
  final requests = await ref.read(urgentBloodRequestsProvider.future);
  if (requests.isEmpty) return false;

  final storage = ref.read(urgentSeenStorageProvider);
  final lastSeen = await storage.getLastSeen(userId);

  final newest = requests
      .where((r) => r.dateCreation != null)
      .map((r) => r.dateCreation!)
      .fold<DateTime?>(null, (prev, curr) {
        if (prev == null) return curr;
        return curr.isAfter(prev) ? curr : prev;
      });

  if (newest == null) return false;
  if (lastSeen == null) return true;

  return newest.isAfter(lastSeen);
});

class UrgentSeenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String _key(int userId) => 'last_seen_urgent_requests_$userId';

  Future<DateTime?> getLastSeen(int userId) async {
    final raw = await _storage.read(key: _key(userId));
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> markSeen(int userId) async {
    await _storage.write(
      key: _key(userId),
      value: DateTime.now().toIso8601String(),
    );
  }
}