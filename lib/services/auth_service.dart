import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hafalyuk_dsn/models/login_model.dart';

class AuthService {
  final String? kcUrl = dotenv.env['KC_URL'];
  final String? clientId = dotenv.env['CLIENT_ID'];
  final String? clientSecret = dotenv.env['CLIENT_SECRET'];
  final _storage = const FlutterSecureStorage();
  final Dio dio = Dio();
  Timer? _refreshTimer;

  AuthService() {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) async {
          if (e.response?.statusCode == 401) {
            try {
              await _refreshToken();
              e.requestOptions.headers['Authorization'] = dio.options.headers['Authorization'];
              final clonedRequest = await dio.fetch(e.requestOptions);
              return handler.resolve(clonedRequest);
            } catch (refreshError) {
              await logout();
              return handler.reject(
                DioException(
                  requestOptions: e.requestOptions,
                  error: 'Session expired. Please log in again.',
                  type: DioExceptionType.badResponse,
                ),
              );
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<LoginRespons> login(String username, String password) async {
    final response = await dio.post(
      '$kcUrl/realms/dev/protocol/openid-connect/token',
      data: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'grant_type': 'password',
        'username': username,
        'password': password,
        'scope': 'openid profile email',
      },
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final loginResponse = LoginRespons.fromJson(data);
      await _storage.write(key: 'access_token', value: loginResponse.accessToken);
      await _storage.write(key: 'refresh_token', value: loginResponse.refreshToken);

      dio.options.headers['Authorization'] = 'Bearer ${loginResponse.accessToken}';
      _scheduleTokenRefresh();
      return loginResponse;
    } else {
      throw Exception('Login failed: ${response.data}');
    }
  }

  Future<String?> getToken() async => await _storage.read(key: 'access_token');
  Future<String?> getRefreshToken() async => await _storage.read(key: 'refresh_token');

  Future<void> logout() async {
    _cancelRefreshTimer();
    await _storage.deleteAll();
    dio.options.headers.remove('Authorization');
  }

  Future<void> _refreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) throw Exception('No refresh token found');

    final response = await dio.post(
      '$kcUrl/realms/dev/protocol/openid-connect/token',
      data: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      },
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );

    if (response.statusCode == 200) {
      final newAccessToken = response.data['access_token'];
      final newRefreshToken = response.data['refresh_token'];

      await _storage.write(key: 'access_token', value: newAccessToken);
      await _storage.write(key: 'refresh_token', value: newRefreshToken);

      dio.options.headers['Authorization'] = 'Bearer $newAccessToken';
      _scheduleTokenRefresh();
    } else {
      throw Exception('Failed to refresh token: ${response.data}');
    }
  }

  void _scheduleTokenRefresh() {
    _cancelRefreshTimer();
    _refreshTimer = Timer(
      const Duration(minutes: 13),
      () async {
        try {
          await _refreshToken();
        } catch (e) {
          await logout();
        }
      },
    );
  }

  void _cancelRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
}