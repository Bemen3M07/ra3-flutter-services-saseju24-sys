import 'package:flutter/material.dart';
import '../models/joke_model.dart';
import '../services/joke_service.dart';

// CONTROLADOR/PROVIDER: Gestiona el estado de los chistes
class JokeProvider extends ChangeNotifier {
  final JokeService _jokeService = JokeService();

  JokeModel? _currentJoke;
  bool _isLoading = false;
  String? _error;

  // Getters
  JokeModel? get currentJoke => _currentJoke;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar un nuevo chiste aleatorio
  Future<void> loadRandomJoke() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentJoke = await _jokeService.getRandomJoke();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _currentJoke = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para limpiar el estado
  void reset() {
    _currentJoke = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
