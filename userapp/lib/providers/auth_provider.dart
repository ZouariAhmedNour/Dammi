import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:userapp/api/api_client.dart';
import 'package:userapp/api/auth_api.dart';
import 'package:userapp/api/storage_service.dart';
import 'package:userapp/models/user.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
}

class AuthController extends ChangeNotifier {
  final AuthApi _authApi;
  final StorageService _storage;

  AuthController(this._authApi, this._storage) {
    loadSession();
  }

  AuthStatus status = AuthStatus.initial;
  User? user;
  String? token;
  String? errorMessage;

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;

  Future<void> loadSession() async {
    status = AuthStatus.loading;
    notifyListeners();

    final storedToken = await _storage.getToken();
    final storedUserJson = await _storage.getUserJson();

    token = storedToken;

    if (storedUserJson != null) {
      user = User.fromRawJson(storedUserJson);
    }

    status = (storedToken != null && storedToken.isNotEmpty)
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;

    notifyListeners();
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      errorMessage = null;
      status = AuthStatus.loading;
      notifyListeners();

      final response = await _authApi.login(
        email: email,
        password: password,
      );

      token = response.token;
      user = response.user ??
          User(
            id: null,
            prenom: '',
            nom: '',
            email: email,
          );

      await _storage.saveSession(
        token: token!,
        user: user,
      );

      status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

 Future<bool> register({
  required String prenom,
  required String nom,
  required String email,
  required String password,
  required String phone,
  required String sexe,
  required int typeSanguinId,
  DateTime? lastDonation,
}) async {
  try {
    errorMessage = null;
    status = AuthStatus.loading;
    notifyListeners();

    final response = await _authApi.register(
      prenom: prenom,
      nom: nom,
      email: email,
      password: password,
      phone: phone,
      sexe: sexe,
      typeSanguinId: typeSanguinId,
      lastDonation: lastDonation,
    );

    // on récupère les données renvoyées par le backend
    token = response.token;
    user = response.user;

    // on ne connecte pas automatiquement
    status = AuthStatus.unauthenticated;
    notifyListeners();

    return true;
  } catch (e) {
    errorMessage = e.toString().replaceFirst('Exception: ', '');
    status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }
}

void updatePertinent(bool value) async {
  if (user == null) return;

  user = User(
    id: user!.id,
    prenom: user!.prenom,
    nom: user!.nom,
    email: user!.email,
    phone: user!.phone,
    sexe: user!.sexe,
    avatar: user!.avatar,
    role: user!.role,
    eligibilityStatus: user!.eligibilityStatus,
    statutPertinent: value,
    lastDonation: user!.lastDonation,
    typeSanguinId: user!.typeSanguinId,
    typeSanguinAboGroup: user!.typeSanguinAboGroup,
  );

  await _storage.saveSession(
    token: token!,
    user: user,
  );

  notifyListeners();
}

  Future<void> logout() async {
    await _storage.clearSession();
    token = null;
    user = null;
    errorMessage = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}



final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) {
  return AuthController(
    ref.read(authApiProvider),
    ref.read(storageServiceProvider),
  );
});