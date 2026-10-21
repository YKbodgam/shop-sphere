import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../errors/failure.dart';

class ApiClient {
  ApiClient(this.storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://dummyjson.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 10),
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (!_isPublic(options.path)) {
            final token = await storage.read(key: 'access_token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final request = error.requestOptions;
          final unauthorized = error.response?.statusCode == 401;
          final retrying = request.extra['authRetry'] == true;
          if (unauthorized && !retrying && !_isPublic(request.path)) {
            final refreshed = await _refreshOnce();
            if (refreshed) {
              request.extra['authRetry'] = true;
              final token = await storage.read(key: 'access_token');
              if (token != null) {
                request.headers['Authorization'] = 'Bearer $token';
              }
              try {
                handler.resolve(await dio.fetch(request));
                return;
              } catch (_) {}
            }
            await storage.delete(key: 'access_token');
            await storage.delete(key: 'refresh_token');
          }
          handler.next(error);
        },
      ),
    );
  }
  bool _isPublic(String path) =>
      path.startsWith('/auth/login') || path.startsWith('/auth/refresh');
  Future<bool>? _refreshing;
  Future<bool> _refreshOnce() {
    return _refreshing ??= _performRefresh().whenComplete(
      () => _refreshing = null,
    );
  }

  Future<bool> _performRefresh() async {
    final refreshToken = await storage.read(key: 'refresh_token');
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      final response = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken, 'expiresInMins': 30},
      );
      final access = response.data['accessToken'] as String?;
      if (access == null || access.isEmpty) return false;
      await storage.write(key: 'access_token', value: access);
      final nextRefresh = response.data['refreshToken'] as String?;
      if (nextRefresh != null && nextRefresh.isNotEmpty) {
        await storage.write(key: 'refresh_token', value: nextRefresh);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  final FlutterSecureStorage storage;
  late final Dio dio;

  Future<Response<dynamic>> request(
    Future<Response<dynamic>> Function() call,
  ) async {
    try {
      return await call();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const TimeoutFailure();
      }
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) throw const UnauthorizedFailure();
      if (status == 404) throw const NotFoundFailure();
      if (status != null && status >= 500) throw const ServerFailure();
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkFailure();
      }
      throw UnknownFailure(e.message ?? 'Request failed.');
    }
  }
}
