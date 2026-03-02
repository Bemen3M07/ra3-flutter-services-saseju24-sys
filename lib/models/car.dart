import 'dart:convert';
import 'package:http/http.dart' as http;

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

// Constructor de objetos a partir de mapa de objetos

  factory CarsModel.fromMapToCarObject(Map<String, dynamic> json) => CarsModel(
      id: json["id"],
      year: json["year"],
      make: json["make"],
      model: json["model"],
      type: json["type"]);

  //Metodo para convertir un objeto de tipo carsmodel a un mapa de objetos

  Map<String, dynamic> fromObjectToMap() => {
        "id": id,
        "year": year,
        "make": make,
        "model": model,
        "type": type,
      };
}

//funcion para obtener una lista de objetos tipo carsmodel a partir de un string json

List<CarsModel> carsModelFromJson(String str) => List<CarsModel>.from(
    json.decode(str).map((x) => CarsModel.fromMapToCarObject(x)));

//funcion para obtener un string json a partir de una lista de objetos tipo CarsModel
String CarsModelToJson(List<CarsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.fromObjectToMap())));

class CarHttpService {
  final String _serverUrl = "https://car-data.p.rapidapi.com";
  final String _headerKey =
      "7c00063cc0mshd06eb3f7234b024p167924jsn67c78b190f6a";
  final String _headerHost = "car-data.p.rapidapi.com";

Future<List<CarsModel>> getCars() async {
  //URL de l'endpoint: es la URL del servidor con la URL del endpoint
  var uri = Uri.parse(
      "$_serverUrl/cars"); 

  //peticion GET i esperamos respuesta
  var response = await http.get(uri, headers: {
    "x-rapidapi-key":
        _headerKey, 
    "x-rapidapi-host":
        _headerHost 
  });

  //Control de errores. Si la respuesta es 200 todo OK.  Sino, ERROR
  if (response.statusCode == 200) {
    return carsModelFromJson(response.body);
  } else {
    throw ("Error al obtenir la llista de cotxes: ${response.statusCode}");
  }
}

}

