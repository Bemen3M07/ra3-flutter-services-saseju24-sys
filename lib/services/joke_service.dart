import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/joke_model.dart';

// SERVICIO: Encargado de consumir la API REST
class JokeService {
  static const String _baseUrl = 'https://api.sampleapis.com/jokes/goodJokes';

  // Obtener todos los chistes de la API
  Future<List<JokeModel>> getAllJokes() async {
    try {
      final uri = Uri.parse(_baseUrl);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => JokeModel.fromJson(json)).toList();
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener chistes: $e');
    }
  }

  // Obtener un chiste aleatorio de la lista
  Future<JokeModel> getRandomJoke() async {
    try {
      final jokes = await getAllJokes();
      if (jokes.isEmpty) {
        throw Exception('No jokes available');
      }
      final randomIndex = Random().nextInt(jokes.length);
      return jokes[randomIndex];
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
