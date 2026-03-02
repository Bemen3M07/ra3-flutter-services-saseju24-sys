// MODELO: Representa un chiste
class JokeModel {
  final int id;
  final String type;
  final String setup;
  final String punchline;

  JokeModel({
    required this.id,
    required this.type,
    required this.setup,
    required this.punchline,
  });

  // Constructor desde JSON
  factory JokeModel.fromJson(Map<String, dynamic> json) {
    return JokeModel(
      id: json['id'] as int,
      type: json['type'] as String,
      setup: json['setup'] as String,
      punchline: json['punchline'] as String,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'setup': setup,
      'punchline': punchline,
    };
  }

  @override
  String toString() => 'Joke(id: $id, type: $type, setup: $setup, punchline: $punchline)';
}
