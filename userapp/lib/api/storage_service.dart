
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:userapp/models/user.dart';

class StorageService {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveSession({
    required String token,
    User? user,
  }) async {
    await _storage.write(key: _tokenKey, value: token);

    if (user != null) {
      await _storage.write(key: _userKey, value: user.toRawJson());
    }
  }

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<String?> getUserJson() => _storage.read(key: _userKey);

  Future<void> clearSession() => _storage.deleteAll();
}