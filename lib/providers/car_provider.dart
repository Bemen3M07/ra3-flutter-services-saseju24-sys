import 'package:flutter/material.dart';
import '../models/car.dart';

class CarProvider extends ChangeNotifier {
  final CarHttpService _carHttpService = CarHttpService();
  
  List<CarsModel> _cars = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CarsModel> get cars => _cars;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Método para obtener los datos de los coches desde la API
  Future<void> getCarsData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cars = await _carHttpService.getCars();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _cars = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
