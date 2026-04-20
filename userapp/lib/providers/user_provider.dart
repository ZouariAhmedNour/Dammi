import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:userapp/api/api_client.dart';
import 'package:userapp/api/user_api.dart';

final userApiProvider = Provider<UserApi>((ref) {
  final dio = ref.watch(dioProvider);
  return UserApi(dio);
});

final statutPertinentProvider =
    StateNotifierProvider<StatutPertinentNotifier, bool>((ref) {
      return StatutPertinentNotifier(ref);
    });

class StatutPertinentNotifier extends StateNotifier<bool> {
  final Ref ref;

  StatutPertinentNotifier(this.ref) : super(false);

  Future<void> toggle(int userId, bool value) async {
    final result = await ref
        .read(userApiProvider)
        .updateStatutPertinent(userId, value);

    state = result;
  }
}