import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:userapp/api/api_client.dart';
import 'package:userapp/api/auth_api.dart';
import 'package:userapp/api/storage_service.dart';
import 'package:userapp/models/app_user.dart';

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
  AppUser? user;
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
      user = AppUser.fromRawJson(storedUserJson);
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
          AppUser(
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
  DateTime? lastDonation,
}) async {
  try {
    errorMessage = null;
    status = AuthStatus.loading;
    notifyListeners();

    await _authApi.register(
      prenom: prenom,
      nom: nom,
      email: email,
      password: password,
      phone: phone,
      sexe: sexe,
      lastDonation: lastDonation,
    );

    // IMPORTANT :
    // on ne connecte pas automatiquement l'utilisateur
    token = null;
    user = null;
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