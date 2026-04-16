import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:userapp/api/donor_api.dart';
import 'package:userapp/models/donor_card_model.dart';
import 'package:userapp/providers/auth_provider.dart';

final donorCardProvider = FutureProvider<DonorCardModel?>((ref) async {
  final auth = ref.watch(authControllerProvider);

  if (auth.user?.id == null) {
    return null;
  }

  return ref.read(donorApiProvider).getCardByUser(auth.user!.id!);
});