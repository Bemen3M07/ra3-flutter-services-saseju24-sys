// MODELO: Representa una parada de autobús
class StopModel {
  final String stopId;
  final String stopName;
  final double latitude;
  final double longitude;
  final String? lines; // Líneas que pasan

  StopModel({
    required this.stopId,
    required this.stopName,
    required this.latitude,
    required this.longitude,
    this.lines,
  });

  factory StopModel.fromJson(Map<String, dynamic> json) {
    return StopModel(
      stopId: json['stop_id'] as String? ?? json['stopId'] as String? ?? '',
      stopName: json['stop_name'] as String? ?? json['stopName'] as String? ?? '',
      latitude: (json['geometry']?['coordinates']?[1] as num?)?.toDouble() ?? 0.0,
      longitude: (json['geometry']?['coordinates']?[0] as num?)?.toDouble() ?? 0.0,
      lines: json['lines'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stop_id': stopId,
      'stop_name': stopName,
      'latitude': latitude,
      'longitude': longitude,
      'lines': lines,
    };
  }

  @override
  String toString() =>
      'Stop(id: $stopId, name: $stopName, lat: $latitude, lon: $longitude)';
}

// MODELO: Representa un autobús en una parada
class BusModel {
  final String routeId;
  final String routeName;
  final String destination;
  final int arrivalTimeSeconds; // Segundos hasta llegada
  final String busStatus; // "no-service", "in-service", etc.

  BusModel({
    required this.routeId,
    required this.routeName,
    required this.destination,
    required this.arrivalTimeSeconds,
    required this.busStatus,
  });

  factory BusModel.fromJson(Map<String, dynamic> json) {
    return BusModel(
      routeId: json['route_id'] as String? ?? json['routeId'] as String? ?? '',
      routeName: json['route_short_name'] as String? ?? json['routeName'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      arrivalTimeSeconds: json['arrival_seconds'] as int? ?? json['arrivalSeconds'] as int? ?? 0,
      busStatus: json['bus_status'] as String? ?? 'unknown',
    );
  }

  // Convierte segundos a minutos para mostrar
  int get arrivalMinutes => (arrivalTimeSeconds / 60).ceil();

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'route_name': routeName,
      'destination': destination,
      'arrival_seconds': arrivalTimeSeconds,
      'bus_status': busStatus,
    };
  }

  @override
  String toString() =>
      'Bus(route: $routeName, dest: $destination, arrival: ${arrivalMinutes}min)';
}

// MODELO: Información de línea de autobús
class LineModel {
  final String routeId;
  final String routeName;
  final String transportType; // "Metro", "Bus", etc.
  final String? operator;

  LineModel({
    required this.routeId,
    required this.routeName,
    required this.transportType,
    this.operator,
  });

  factory LineModel.fromJson(Map<String, dynamic> json) {
    return LineModel(
      routeId: json['route_id'] as String? ?? '',
      routeName: json['route_short_name'] as String? ?? json['name'] as String? ?? '',
      transportType: json['route_type'] as String? ?? 'Bus',
      operator: json['agency_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'route_name': routeName,
      'transport_type': transportType,
      'operator': operator,
    };
  }

  @override
  String toString() => 'Line(name: $routeName, type: $transportType)';
}
