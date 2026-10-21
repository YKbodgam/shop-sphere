import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/network/api_client.dart';
import '../../core/errors/failure.dart';
import '../../core/network/endpoints.dart';

class SessionUser {
  const SessionUser({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.image,
  });
  final int id;
  final String username, firstName, lastName, email, phone;
  final String? image;
  String get name => '$firstName $lastName';
  factory SessionUser.fromJson(Map<String, dynamic> j) => SessionUser(
    id: (j['id'] as num?)?.toInt() ?? 0,
    username: j['username'] as String? ?? '',
    firstName: j['firstName'] as String? ?? '',
    lastName: j['lastName'] as String? ?? '',
    email: j['email'] as String? ?? '',
    phone: j['phone'] as String? ?? '',
    image: j['image'] as String?,
  );
}

class AuthRepository {
  AuthRepository(this.api, this.storage);
  final ApiClient api;
  final FlutterSecureStorage storage;
  Future<SessionUser> login(String username, String password) async {
    final r = await api.request(
      () => api.dio.post(
        Endpoints.login,
        data: {'username': username, 'password': password, 'expiresInMins': 30},
      ),
    );
    final data = Map<String, dynamic>.from(r.data as Map);
    final access = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;
    if (access == null ||
        access.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      throw const UnknownFailure('The sign-in response was incomplete.');
    }
    try {
      await _writeTokens(access, refreshToken);
    } on StorageFailure {
      rethrow;
    }
    return SessionUser.fromJson(data);
  }

  Future<SessionUser> restore() async {
    final token = await storage.read(key: 'access_token');
    if (token == null || token.isEmpty) throw StateError('no_session');
    try {
      final r = await api.request(() => api.dio.get(Endpoints.me));
      return SessionUser.fromJson(Map<String, dynamic>.from(r.data));
    } on UnauthorizedFailure {
      final refreshed = await refresh();
      if (!refreshed) rethrow;
      final r = await api.request(() => api.dio.get(Endpoints.me));
      return SessionUser.fromJson(Map<String, dynamic>.from(r.data));
    }
  }

  Future<bool> refresh() async {
    final refreshToken = await storage.read(key: 'refresh_token');
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      final response = await api.dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken, 'expiresInMins': 30},
      );
      final access = response.data['accessToken'] as String?;
      if (access == null || access.isEmpty) return false;
      final nextRefresh = response.data['refreshToken'] as String?;
      await _writeTokens(
        access,
        nextRefresh?.isNotEmpty == true ? nextRefresh! : refreshToken,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<SessionUser> me() => restore();

  Future<void> _writeTokens(String access, String refresh) async {
    try {
      await storage.write(key: 'access_token', value: access);
      await storage.write(key: 'refresh_token', value: refresh);
    } catch (_) {
      try {
        await storage.delete(key: 'access_token');
        await storage.delete(key: 'refresh_token');
      } catch (_) {}
      throw const StorageFailure();
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
  }
}
