import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tmb_models.dart';

/// SERVEI TMB - iBus API
/// Credencials: https://developer.tmb.cat/
///
/// Endpoints implementats:
///   1. GET /itransit/bus/parades/{codi}  → parada + busos en temps real
///   2. GET /itransit/bus/parades/        → totes les parades
///   3. GET /transit/linies/bus/          → totes les línies de bus
class TMBService {
  static const String _appId  = '0d4bcf3c';
  static const String _apiKey = '23cf9aa8a5320d3f5452104b25fccb37';
  static const String _baseUrl = 'https://api.tmb.cat/v1';

  /// ENDPOINT 1: Cercar parada per codi i obtenir busos en temps real
  /// GET /itransit/bus/parades/{codi_parada}
  Future<List<StopModel>> searchStopByCode(String stopCode) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/itransit/bus/parades/$stopCode?app_id=$_appId&app_key=$_apiKey',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> parades = jsonData['parades'] ?? [];
        return parades.map((p) => StopModel.fromJson(p)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error cercant parada: $e');
    }
  }

  /// ENDPOINT 2: Obtenir autobusos d'una parada (crida individual)
  /// GET /itransit/bus/parades/{stopId}
  Future<List<BusModel>> getBusesAtStop(String stopId) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/itransit/bus/parades/$stopId?app_id=$_appId&app_key=$_apiKey',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> parades = jsonData['parades'] ?? [];
        if (parades.isEmpty) return [];
        // Busquem la parada exacta pel codi
        final parada = parades.firstWhere(
          (p) => p['codi_parada'].toString() == stopId,
          orElse: () => parades[0],
        );
        final List<dynamic> linies = parada['linies_trajectes'] ?? [];
        return linies.map((l) => BusModel.fromJson(l)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error obtenint autobusos: $e');
    }
  }

  /// ENDPOINT 3: Obtenir totes les línies de bus
  /// GET /transit/linies/bus/
  Future<List<LineModel>> getTransitLines() async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/transit/linies/bus/?app_id=$_appId&app_key=$_apiKey',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> features = jsonData['features'] ?? [];
        return features
            .map((f) => LineModel.fromJson(f['properties'] ?? f))
            .toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error obtenint línies: $e');
    }
  }

  /// ENDPOINT ADDICIONAL: Totes les parades (sense filtre)
  /// GET /itransit/bus/parades/
  Future<List<StopModel>> getNearbyStops(
    double latitude,
    double longitude, {
    int radiusMeters = 500,
  }) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/itransit/bus/parades/?app_id=$_appId&app_key=$_apiKey',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> parades = jsonData['parades'] ?? [];
        return parades.take(20).map((p) => StopModel.fromJson(p)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error obtenint parades: $e');
    }
  }
}
