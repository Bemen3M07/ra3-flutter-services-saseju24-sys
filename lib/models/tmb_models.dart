// MODELO: Representa una parada de autobús
class StopModel {
  final String stopId;
  final String stopName;
  final List<BusModel> buses;

  StopModel({
    required this.stopId,
    required this.stopName,
    this.buses = const [],
  });

  factory StopModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> linies = json['linies_trajectes'] ?? [];
    return StopModel(
      stopId:   (json['codi_parada'] ?? '').toString(),
      stopName: (json['nom_parada']  ?? '').toString(),
      buses: linies.map((l) => BusModel.fromJson(l)).toList(),
    );
  }

  @override
  String toString() => 'Stop(id: $stopId, name: $stopName)';
}

// MODELO: Representa una línia amb els pròxims autobusos
class BusModel {
  final String routeName;
  final String destination;
  final int arrivalTimestamp; // ms epoch
  final String busStatus;

  BusModel({
    required this.routeName,
    required this.destination,
    required this.arrivalTimestamp,
    required this.busStatus,
  });

  factory BusModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> propersBusos = json['propers_busos'] ?? [];
    final int tempsArr = propersBusos.isNotEmpty
        ? (propersBusos[0]['temps_arribada'] ?? 0) as int
        : 0;
    return BusModel(
      routeName:        (json['nom_linia']      ?? '').toString(),
      destination:      (json['desti_trajecte'] ?? '').toString(),
      arrivalTimestamp: tempsArr,
      busStatus:        propersBusos.isNotEmpty ? 'En servei' : 'Sense servei',
    );
  }

  // Minuts fins a l'arribada calculats des del timestamp en ms
  int get arrivalMinutes {
    if (arrivalTimestamp == 0) return 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = arrivalTimestamp - now;
    return (diff / 60000).ceil().clamp(0, 999);
  }

  // Getter de compatibilitat
  int get arrivalTimeSeconds => (arrivalTimestamp / 1000).round();

  @override
  String toString() =>
      'Bus(route: $routeName, dest: $destination, arrival: ${arrivalMinutes}min)';
}

// MODELO: Informació d'una línia de bus
class LineModel {
  final String routeId;
  final String routeName;
  final String transportType;
  final String? operator;

  LineModel({
    required this.routeId,
    required this.routeName,
    required this.transportType,
    this.operator,
  });

  factory LineModel.fromJson(Map<String, dynamic> json) {
    return LineModel(
      routeId:       (json['CODI_LINIA'] ?? json['codi_linia'] ?? json['route_id'] ?? '').toString(),
      routeName:     (json['NOM_LINIA']  ?? json['nom_linia']  ?? json['name']     ?? '').toString(),
      transportType: (json['TIPUS_VEHICLE'] ?? json['transit_namespace'] ?? 'Bus').toString(),
      operator:      (json['NOM_OPERADOR'] ?? json['agency_name'])?.toString(),
    );
  }

  @override
  String toString() => 'Line(id: $routeId, name: $routeName)';
}
