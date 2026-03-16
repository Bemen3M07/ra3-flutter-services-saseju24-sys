import 'dart:convert';
import 'package:http/http.dart' as http;

// MODELO: Representa un coche obtenido de la API
class CarsModel {
  final int id;
  final int year;
  final String make;
  final String model;
  final String type;

  CarsModel({
    required this.id,
    required this.year,
    required this.make,
    required this.model,
    required this.type,
  });

  // Constructor de objetos a partir de mapa de objetos (deserialización)
  factory CarsModel.fromMapToCarObject(Map<String, dynamic> json) => CarsModel(
        id: json["id"],
        year: json["year"],
        make: json["make"],
        model: json["model"],
        type: json["type"],
      );

  // Método para convertir un objeto de tipo CarsModel a un mapa de objetos (serialización)
  Map<String, dynamic> fromObjectToMap() => {
        "id": id,
        "year": year,
        "make": make,
        "model": model,
        "type": type,
      };

  @override
  String toString() =>
      'CarsModel(id: $id, year: $year, make: $make, model: $model, type: $type)';
}

// Función para obtener una lista de objetos CarsModel a partir de un string JSON
// CORRECCIÓN: nombre en minúscula siguiendo convenciones Dart (lowerCamelCase)
List<CarsModel> carsModelFromJson(String str) => List<CarsModel>.from(
    json.decode(str).map((x) => CarsModel.fromMapToCarObject(x)));

// Función para obtener un string JSON a partir de una lista de objetos CarsModel
// CORRECCIÓN: nombre en minúscula siguiendo convenciones Dart
String carsModelToJson(List<CarsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.fromObjectToMap())));

// SERVICIO HTTP: Encapsula la lógica de conexión con la API de coches
class CarHttpService {
  final String _serverUrl = "https://car-data.p.rapidapi.com";
  final String _headerKey =
      "7c00063cc0mshd06eb3f7234b024p167924jsn67c78b190f6a";
  final String _headerHost = "car-data.p.rapidapi.com";

  // Obtener lista de coches desde la API
  Future<List<CarsModel>> getCars() async {
    // URL del endpoint: servidor + ruta
    var uri = Uri.parse("$_serverUrl/cars");

    // Petición GET con cabeceras requeridas por RapidAPI
    var response = await http.get(uri, headers: {
      "x-rapidapi-key": _headerKey,
      "x-rapidapi-host": _headerHost,
    });

    // Control de errores: 200 = OK, cualquier otro código = error
    if (response.statusCode == 200) {
      return carsModelFromJson(response.body);
    } else {
      throw Exception(
          "Error al obtenir la llista de cotxes: ${response.statusCode}");
    }
  }
}
