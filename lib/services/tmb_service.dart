import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tmb_models.dart';

/// SERVICIO TMB: Consume la API de transporte de Barcelona
/// 
/// Registrate en: https://developer.tmb.cat/
/// Documentación: https://developer.tmb.cat/api-docs/v1
/// 
/// ⚠️ CONFIGURA TUS CREDENCIALES AQUÍ:
class TMBService {
  // TODO: Reemplaza estos valores con tus credenciales
  static const String _appId = 'TU_APP_ID_AQUI';
  static const String _apiKey = 'TU_API_KEY_AQUI';
  static const String _baseUrl = 'https://api.tmb.cat/v1';

  /// ENDPOINT 1: Buscar paradas por código o nombre
  /// GET /pois/?searchType=stopCode&searchText={code}
  Future<List<StopModel>> searchStopByCode(String stopCode) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/pois/?searchType=stopCode&searchText=$stopCode&app_id=$_appId&app_key=$_apiKey',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> features = jsonData['features'] ?? [];

        return features
            .map((feature) => StopModel.fromJson(feature['properties']))
            .toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error buscando parada: $e');
    }
  }

  /// ENDPOINT 2: Obtener autobuses que pasan por una parada específica
  /// GET /pois/{stopId}/buses
  Future<List<BusModel>> getBusesAtStop(String stopId) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/pois/$stopId/buses?app_id=$_appId&app_key=$_apiKey',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> buses = jsonData['data']?['buses'] ?? [];

        return buses.map((bus) => BusModel.fromJson(bus)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error obteniendo autobuses: $e');
    }
  }

  /// ENDPOINT 3: Obtener todas las líneas de transporte disponibles
  /// GET /transit/lines
  Future<List<LineModel>> getTransitLines() async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/transit/lines?app_id=$_appId&app_key=$_apiKey',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> lines = jsonData['data'] ?? [];

        return lines.map((line) => LineModel.fromJson(line)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error obteniendo líneas: $e');
    }
  }

  /// ENDPOINT ADICIONAL: Obtener paradas cercanas a coordenadas
  /// GET /transit/near/{latitude}/{longitude}
  Future<List<StopModel>> getNearbyStops(
    double latitude,
    double longitude, {
    int radiusMeters = 500,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/transit/near/$latitude/$longitude?radius=$radiusMeters&app_id=$_appId&app_key=$_apiKey',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> features = jsonData['features'] ?? [];

        return features
            .map((feature) => StopModel.fromJson(feature['properties']))
            .toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error obteniendo paradas cercanas: $e');
    }
  }
}
