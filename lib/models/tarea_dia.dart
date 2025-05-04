// Modelo que representa la relación entre una tarea y un día de la semana
class TareaDia {
  final int? id; // ID de la fila en la tabla. Opcional porque SQLite lo genera automáticamente
  final String tareaId; // ID de la tarea (UUID)
  final int diaSemanaId; // ID del día de la semana (1=Lunes, 2=Martes, etc.)
  final String horaInicio; // Hora de inicio de la tarea (formato HH:mm)
  final String horaTermino; // Hora de término de la tarea (formato HH:mm)

  TareaDia({
    this.id, // Ahora es opcional
    required this.tareaId,
    required this.diaSemanaId,
    required this.horaInicio,
    required this.horaTermino,
  });

  // Convertimos la clase en un mapa para guardar en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'tareaId': tareaId,
      'diaSemanaId': diaSemanaId,
      'horaInicio': horaInicio,
      'horaTermino': horaTermino,
    };
    // NOTA: No incluimos 'id' porque SQLite lo genera automáticamente
  }

  // Método para crear una instancia de TareaDia desde un mapa (registro de la base de datos)
  factory TareaDia.fromMap(Map<String, dynamic> map) {
    return TareaDia(
      id: map['id'] as int?, // ID autogenerado por SQLite
      tareaId: map['tareaId'] as String, // ID de la tarea
      diaSemanaId: map['diaSemanaId'] as int, // Día de la semana
      horaInicio: map['horaInicio'] as String, // Hora de inicio
      horaTermino: map['horaTermino'] as String, // Hora de término
    );
  }
}


