import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hafalyuk_dsn/models/pa_model.dart';
import 'package:hafalyuk_dsn/models/setoran_model.dart';
import 'package:hafalyuk_dsn/services/auth_service.dart';

class PaService {
  final Dio dio;
  final AuthService _authService;
  final String? apiUrl = dotenv.env['URL_API'];
  final String? baseUrl = dotenv.env['BASE_URL'];

  PaService(this.dio, this._authService) {
    dio.interceptors.addAll(_authService.dio.interceptors);
  }

  Future<PaRespons> getPaData() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No access token found');

      final response = await dio.get(
        '$apiUrl$baseUrl/dosen/pa-saya',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return PaRespons.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch PA data: $e');
    }
  }

  Future<SetoranRespons> getSetoranData(String nim) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No access token found');

      final response = await dio.get(
        '$apiUrl$baseUrl/mahasiswa/setoran/$nim',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return SetoranRespons.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch Setoran data: $e');
    }
  }

  Future<void> markAsSudahSetor(String nim, List<Map<String, String>> setoranItems) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No access token found');

      await dio.post(
        '$apiUrl$baseUrl/mahasiswa/setoran/$nim',
        data: {
          "data_setoran": setoranItems.map((item) => {
                "nama_komponen_setoran": item['nama_komponen_setoran'],
                "id_komponen_setoran": item['id_komponen_setoran'],
              }).toList(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to mark as Sudah Setor: $e');
    }
  }

  Future<void> markAsBelumSetor(String nim, List<Map<String, String>> setoranItems) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No access token found');

      await dio.delete(
        '$apiUrl$baseUrl/mahasiswa/setoran/$nim',
        data: {
          "data_setoran": setoranItems.map((item) => {
                "id": item['id'],
                "id_komponen_setoran": item['id_komponen_setoran'],
                "nama_komponen_setoran": item['nama_komponen_setoran'],
              }).toList(),
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      throw Exception('Failed to mark as Belum Setor: $e');
    }
  }
}