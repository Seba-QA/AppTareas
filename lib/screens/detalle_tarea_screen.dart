import 'package:flutter/material.dart';
import '../models/tarea.dart';
import '../models/tarea_dia.dart';
import '../screens/editar_tarea_screen.dart'; // Asegúrate de que el path sea correcto

class DetalleTareaScreen extends StatelessWidget {
  final Tarea tarea;
  final TareaDia tareaDia; // Asegúrate de importar el modelo

  const DetalleTareaScreen({
    Key? key,
    required this.tarea,
    required this.tareaDia,
  }) : super(key: key);

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
                  onPressed: () {
                    // Lógica para eliminar la tarea
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
