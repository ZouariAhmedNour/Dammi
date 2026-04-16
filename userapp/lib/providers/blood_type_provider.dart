import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:userapp/api/lookup_api.dart';
import 'package:userapp/models/blood_type.dart';

final bloodTypesProvider = FutureProvider<List<BloodType>>((ref) async {
  return ref.read(lookupApiProvider).getBloodTypes();
});