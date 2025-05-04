/// Modelo que representa una Tarea
class Tarea {
  final String id; // Identificador único
  final String titulo; // Nombre de la tarea
  final String descripcion; // Descripción de la tarea
  final String etiqueta; // Etiqueta o categoría
  final String estado; // Estado: No comenzada, En proceso, Finalizada
  final String prioridad; // Baja, Media, Alta
  final bool notificacion; // Si tiene notificación o no

  Tarea({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.etiqueta,
    required this.estado,
    required this.prioridad,
    required this.notificacion,
  });

  /// Convierte el modelo a un Map para la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'etiqueta': etiqueta,
      'estado': estado,
      'prioridad': prioridad,
      'notificacion': notificacion ? 1 : 0, // Convertimos bool a int
    };
  }

  /// Crea una instancia del modelo a partir de un Map (lectura de la BD)
  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      id: map['id'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      etiqueta: map['etiqueta'],
      estado: map['estado'],
      prioridad: map['prioridad'],
      notificacion: map['notificacion'] == 1, // Convertimos int a bool
    );
  }

  Tarea copyWith({
  String? id,
  String? titulo,
  String? descripcion,
  String? etiqueta,
  String? estado,
  String? prioridad,
  bool? notificacion,
    }) {
      return Tarea(
        id: id ?? this.id,
        titulo: titulo ?? this.titulo,
        descripcion: descripcion ?? this.descripcion,
        etiqueta: etiqueta ?? this.etiqueta,
        estado: estado ?? this.estado,
        prioridad: prioridad ?? this.prioridad,
        notificacion: notificacion ?? this.notificacion,
      );
    }
}
