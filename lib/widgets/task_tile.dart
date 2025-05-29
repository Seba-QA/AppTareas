import 'package:flutter/material.dart';
import '../models/tarea.dart';

class TaskTile extends StatelessWidget {
  final Tarea tarea;
  final VoidCallback?
  onTap; // Callback al tocar toda la tarjeta (para ver detalle)
  final VoidCallback? onEstadoTap; // Callback específico para cambiar el estado

  const TaskTile({
    super.key,
    required this.tarea,
    this.onTap,
    this.onEstadoTap,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap:
          onTap, // ✅ Permite que al tocar toda la tarjeta se ejecute el callback para ir al detalle
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(10),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            tileColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),

            // 👇 Acción al tocar toda la tarea (excepto el ícono de estado)
            onTap: onTap,

            // ✅ Parte izquierda: indicador de prioridad
            leading: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _obtenerColorPrioridad(tarea.prioridad),
                shape: BoxShape.circle,
              ),
            ),

            // 📄 Parte central: título de la tarea
            title: Text(
              tarea.titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            // ✅ Parte derecha: ícono de estado
            trailing:
                tarea.estado.toLowerCase() != 'no realizado'
                    ? GestureDetector(
                      onTap: onEstadoTap,
                      child: Icon(
                        _obtenerIconoEstado(tarea.estado),
                        color: _obtenerColorEstado(tarea.estado),
                      ),
                    )
                    : Icon(
                      _obtenerIconoEstado(tarea.estado),
                      color: _obtenerColorEstado(tarea.estado),
                    ),
          ),
        ),
      ),
    );
  }

  // Devuelve el ícono correspondiente según el estado
  IconData _obtenerIconoEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'finalizada':
        return Icons.check_circle;
      case 'no realizado':
        return Icons.cancel;
      default:
        return Icons.access_time;
    }
  }

  // Devuelve el color del ícono según el estado
  Color _obtenerColorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'finalizada':
        return Colors.green;
      case 'no realizado':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // Devuelve un color según la prioridad de la tarea
  Color _obtenerColorPrioridad(String prioridad) {
    switch (prioridad.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
      default:
        return Colors.green;
    }
  }
}
