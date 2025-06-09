

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

  Future<void> markAsSudahSetor(String nim, String idKomponen, String namaKomponen) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No access token found');

      await dio.post(
        '$apiUrl$baseUrl/mahasiswa/setoran/$nim',
        data: {
          "data_setoran": [
            {
              "nama_komponen_setoran": namaKomponen,
              "id_komponen_setoran": idKomponen,
            }
          ]
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

  Future<void> markAsBelumSetor(String nim, String idSetoran, String idKomponen, String namaKomponen) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('No access token found');

      await dio.delete(
        '$apiUrl$baseUrl/mahasiswa/setoran/$nim',
        data: {
          "data_setoran": [
            {
              "id": idSetoran,
              "id_komponen_setoran": idKomponen,
              "nama_komponen_setoran": namaKomponen,
            }
          ]
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
