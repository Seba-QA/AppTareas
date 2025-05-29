import 'package:flutter/material.dart';
import '../models/tarea.dart';
import '../models/tarea_dia.dart';
import '../screens/editar_tarea_screen.dart';
import '../db/db_helper.dart';

class DetalleTareaScreen extends StatelessWidget {
  final Tarea tarea;
  final TareaDia tareaDia; // Asegúrate de importar el modelo
  final DatabaseHelper _dbHelper = DatabaseHelper();

  DetalleTareaScreen({Key? key, required this.tarea, required this.tareaDia})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de la Tarea')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📝 Título: ${tarea.titulo}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '📄 Descripción: ${tarea.descripcion}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '🔺 Prioridad: ${tarea.prioridad}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '⏱ Estado: ${tarea.estado}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '🕒 Inicio: ${tareaDia.horaInicio}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '🕓 Término: ${tareaDia.horaTermino}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '🔔 Notificaciones activas: ${tarea.notificacion ? '✅' : '❌'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '📅 Días asignados: (pendiente)',
              style: const TextStyle(fontSize: 16),
            ),

            const Spacer(),

            // Botones alineados a la derecha
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Marcar como finalizada',
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () {
                    // Lógica para marcar como finalizada
                  },
                ),
                IconButton(
                  tooltip: 'Editar tarea',
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    // Lógica para editar la tarea
                    debugPrint('Botón editar presionado');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditarTareaScreen(tarea: tarea),
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Eliminar tarea',
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    final confirmacion = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Confirmar eliminación'),
                            content: const Text(
                              '¿Estás seguro de que deseas eliminar esta tarea?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                    );
                    if (confirmacion == true) {
                      await _dbHelper.eliminarTarea(tarea.id);
                      if (context.mounted)
                        Navigator.pop(
                          context,
                          true,
                        ); // Volver a la pantalla anterior
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
