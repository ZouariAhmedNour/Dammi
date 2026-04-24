import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:userapp/api/api_client.dart';
import 'package:userapp/api/donor_card_api.dart';
import 'package:userapp/models/donor_card_model.dart';
import 'package:userapp/providers/auth_provider.dart';

final donorCardApiProvider = Provider<DonorCardApi>((ref) {
  return DonorCardApi(ref.read(dioProvider));
});

final donorCardAccessProvider = FutureProvider<bool?>((ref) async {
  final auth = ref.watch(authControllerProvider);
  final user = auth.user;

  if (user == null || user.id == null) return null;

  return ref.read(donorCardApiProvider).getAccessStatus(user.id!);
});

final donorCardProvider = FutureProvider<DonorCard?>((ref) async {
  final auth = ref.watch(authControllerProvider);
  final user = auth.user;

  if (user == null || user.id == null) return null;

  return ref.read(donorCardApiProvider).getCardByUser(user.id!);
});