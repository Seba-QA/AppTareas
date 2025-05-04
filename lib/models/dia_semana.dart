/// Modelo que representa un Día de la Semana
class DiaSemana {
  final int id; // Identificador único del día
  final String nombreDia; // Nombre del día (Lunes, Martes, etc.)

  DiaSemana({
    required this.id,
    required this.nombreDia,
  });

  /// Convierte el modelo a un Map para la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombreDia': nombreDia,
    };
  }

  /// Crea una instancia del modelo a partir de un Map (lectura de la BD)
  factory DiaSemana.fromMap(Map<String, dynamic> map) {
    return DiaSemana(
      id: map['id'],
      nombreDia: map['nombreDia'],
    );
  }
}
