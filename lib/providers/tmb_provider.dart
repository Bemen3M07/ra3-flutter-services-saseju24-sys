import 'package:flutter/material.dart';
import '../models/tmb_models.dart';
import '../services/tmb_service.dart';

/// CONTROLADOR/PROVIDER: Gestiona l'estat de l'app de transport TMB
class TMBProvider extends ChangeNotifier {
  final TMBService _tmbService = TMBService();

  // Estats per a la cerca de parades
  List<StopModel> _stops = [];
  bool _isLoadingStops = false;
  String? _errorStops;

  // Estats per als autobusos d'una parada
  List<BusModel> _buses = [];
  bool _isLoadingBuses = false;
  String? _errorBuses;
  StopModel? _selectedStop;

  // Estats per a les línies
  List<LineModel> _lines = [];
  bool _isLoadingLines = false;
  String? _errorLines;

  // Getters parades
  List<StopModel> get stops        => _stops;
  bool            get isLoadingStops => _isLoadingStops;
  String?         get errorStops   => _errorStops;

  // Getters autobusos
  List<BusModel>  get buses          => _buses;
  bool            get isLoadingBuses => _isLoadingBuses;
  String?         get errorBuses     => _errorBuses;
  StopModel?      get selectedStop   => _selectedStop;

  // Getters línies
  List<LineModel> get lines          => _lines;
  bool            get isLoadingLines => _isLoadingLines;
  String?         get errorLines     => _errorLines;

  /// ENDPOINT 1: Cercar parada per codi
  Future<void> searchStop(String stopCode) async {
    _isLoadingStops = true;
    _errorStops = null;
    _stops = [];
    notifyListeners();

    try {
      _stops = await _tmbService.searchStopByCode(stopCode);
      if (_stops.isEmpty) {
        _errorStops = 'No s\'han trobat parades amb el codi: $stopCode';
      }
    } catch (e) {
      _errorStops = e.toString();
    } finally {
      _isLoadingStops = false;
      notifyListeners();
    }
  }

  /// ENDPOINT 2: Obtenir autobusos d'una parada
  Future<void> getBusesAtStop(StopModel stop) async {
    _selectedStop = stop;
    _isLoadingBuses = true;
    _errorBuses = null;
    _buses = [];
    notifyListeners();

    try {
      _buses = await _tmbService.getBusesAtStop(stop.stopId);
      if (_buses.isEmpty) {
        _errorBuses = 'No hi ha autobusos propers en aquesta parada';
      }
    } catch (e) {
      _errorBuses = e.toString();
    } finally {
      _isLoadingBuses = false;
      notifyListeners();
    }
  }

  /// ENDPOINT 3: Obtenir totes les línies
  Future<void> loadAllLines() async {
    _isLoadingLines = true;
    _errorLines = null;
    _lines = [];
    notifyListeners();

    try {
      _lines = await _tmbService.getTransitLines();
    } catch (e) {
      _errorLines = e.toString();
    } finally {
      _isLoadingLines = false;
      notifyListeners();
    }
  }

  /// Netejar tots els estats
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
