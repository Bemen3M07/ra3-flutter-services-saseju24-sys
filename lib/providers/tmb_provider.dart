import 'package:flutter/material.dart';
import '../models/tmb_models.dart';
import '../services/tmb_service.dart';

/// CONTROLADOR/PROVIDER: Gestiona el estado de la app de transporte TMB
class TMBProvider extends ChangeNotifier {
  final TMBService _tmbService = TMBService();

  // Estados para búsqueda de paradas
  List<StopModel> _stops = [];
  bool _isLoadingStops = false;
  String? _errorStops;

  // Estados para autobuses en parada
  List<BusModel> _buses = [];
  bool _isLoadingBuses = false;
  String? _errorBuses;
  StopModel? _selectedStop;

  // Estados para líneas
  List<LineModel> _lines = [];
  bool _isLoadingLines = false;
  String? _errorLines;

  // Getters para paradas
  List<StopModel> get stops => _stops;
  bool get isLoadingStops => _isLoadingStops;
  String? get errorStops => _errorStops;

  // Getters para autobuses
  List<BusModel> get buses => _buses;
  bool get isLoadingBuses => _isLoadingBuses;
  String? get errorBuses => _errorBuses;
  StopModel? get selectedStop => _selectedStop;

  // Getters para líneas
  List<LineModel> get lines => _lines;
  bool get isLoadingLines => _isLoadingLines;
  String? get errorLines => _errorLines;

  /// Buscar parada por código (Endpoint 1)
  Future<void> searchStop(String stopCode) async {
    _isLoadingStops = true;
    _errorStops = null;
    _stops = [];
    notifyListeners();

    try {
      _stops = await _tmbService.searchStopByCode(stopCode);
      _errorStops = null;

      if (_stops.isEmpty) {
        _errorStops = 'No se encontraron paradas con el código: $stopCode';
      }
    } catch (e) {
      _errorStops = e.toString();
      _stops = [];
    } finally {
      _isLoadingStops = false;
      notifyListeners();
    }
  }

  /// Obtener autobuses en una parada (Endpoint 2)
  Future<void> getBusesAtStop(StopModel stop) async {
    _selectedStop = stop;
    _isLoadingBuses = true;
    _errorBuses = null;
    _buses = [];
    notifyListeners();

    try {
      _buses = await _tmbService.getBusesAtStop(stop.stopId);
      _errorBuses = null;

      if (_buses.isEmpty) {
        _errorBuses = 'No hay autobuses próximos en esta parada';
      }
    } catch (e) {
      _errorBuses = e.toString();
      _buses = [];
    } finally {
      _isLoadingBuses = false;
      notifyListeners();
    }
  }

  /// Obtener todas las líneas (Endpoint 3)
  Future<void> loadAllLines() async {
    _isLoadingLines = true;
    _errorLines = null;
    _lines = [];
    notifyListeners();

    try {
      _lines = await _tmbService.getTransitLines();
      _errorLines = null;
    } catch (e) {
      _errorLines = e.toString();
      _lines = [];
    } finally {
      _isLoadingLines = false;
      notifyListeners();
    }
  }

  /// Obtener paradas cercanas (Endpoint adicional)
  Future<void> getNearbyStops(double latitude, double longitude) async {
    _isLoadingStops = true;
    _errorStops = null;
    _stops = [];
    notifyListeners();

    try {
      _stops = await _tmbService.getNearbyStops(latitude, longitude);
      _errorStops = null;

      if (_stops.isEmpty) {
        _errorStops = 'No hay paradas cercanas';
      }
    } catch (e) {
      _errorStops = e.toString();
      _stops = [];
    } finally {
      _isLoadingStops = false;
      notifyListeners();
    }
  }

  /// Limpiar todos los estados
  void reset() {
    _stops = [];
    _buses = [];
    _lines = [];
    _selectedStop = null;
    _errorStops = null;
    _errorBuses = null;
    _errorLines = null;
    notifyListeners();
  }
}
