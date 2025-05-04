import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/tarea.dart';
import '../widgets/task_tile.dart';
import 'dart:async';
import 'detalle_tarea_screen.dart';

class ListaTareasDiaScreen extends StatefulWidget {
  final int diaSemanaId;
  final String nombreDia;

  const ListaTareasDiaScreen({
    super.key,
    required this.diaSemanaId,
    required this.nombreDia,
  });

  @override
  State<ListaTareasDiaScreen> createState() => _ListaTareasDiaScreenState();
}

class _ListaTareasDiaScreenState extends State<ListaTareasDiaScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<Tarea>> _tareasFuture;
  Timer? _verificacionTimer;

  @override
  void initState() {
    super.initState();
    _cargarTareas();

    // Verifica y actualiza cada minuto
    _verificacionTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _cargarTareas(),
    );
  }

  @override
  void dispose() {
    _verificacionTimer?.cancel(); // Aquí cancelas el Timer
    super.dispose();
  }

  void _cargarTareas() {
    _tareasFuture = _dbHelper.getTareasPorDia(widget.diaSemanaId);
    _tareasFuture.then((tareas) async {
      await _verificarYActualizarEstadoTareas(tareas);

      // ⚠️ Esperamos brevemente antes de recargar, para que se reflejen cambios
      await Future.delayed(const Duration(milliseconds: 300));

      final tareasActualizadas = await _dbHelper.getTareasPorDia(
        widget.diaSemanaId,
      );
      setState(() {
        _tareasFuture = Future.value(tareasActualizadas);
      });
    });
  }

  /// Verifica si una tarea ya venció (hora de término pasada) y no fue finalizada.
  /// Si cumple esa condición, se actualiza su estado a "No realizada".
  Future<void> _verificarYActualizarEstadoTareas(List<Tarea> tareas) async {
    final ahora = TimeOfDay.now();

    for (Tarea tarea in tareas) {
      // Nos aseguramos de que la tarea no esté ya finalizada (ignoramos mayúsculas)
      if (tarea.estado.toLowerCase() != 'finalizada') {
        // Obtenemos todas las relaciones entre tarea y día
        final relaciones = await _dbHelper.getRelacionesTarea(tarea.id);

        for (var relacion in relaciones) {
          // Convertimos la hora de término de la tarea a TimeOfDay
          final partes = relacion.horaTermino.split(':');
          final hora = int.tryParse(partes[0]) ?? 0;
          final minuto = int.tryParse(partes[1]) ?? 0;
          final horaTermino = TimeOfDay(hour: hora, minute: minuto);
          final horaFormateada =
              '${horaTermino.hour}:${horaTermino.minute.toString().padLeft(2, '0')}';

          final terminoPasado = _esHoraPasada(horaFormateada);

          debugPrint(
            '⏱ Verificando ${tarea.titulo} -> Hora término: ${relacion.horaTermino}, '
            'Ahora: ${ahora.format(context)}, ¿Pasó?: $terminoPasado',
          );

          if (terminoPasado) {
            // Si ya pasó la hora y la tarea no está finalizada, marcamos como "No realizado"
            final tareaActualizada = tarea.copyWith(estado: 'No realizado');
            await _dbHelper.actualizarEstadoTarea(tareaActualizada);

            debugPrint('❌ Tarea ${tarea.titulo} marcada como NO REALIZADA');
            break; // Solo una actualización por tarea
          }
        }
      }
    }
  }

  /// Verifica si la hora de término de la tarea ya ha pasado para hoy
  bool _esHoraPasada(String horaTermino) {
    final ahora = TimeOfDay.now();

    final partes = horaTermino.split(':');
    final hora = int.parse(partes[0]);
    final minuto = int.parse(partes[1]);

    // Comparación simple con la hora actual
    if (ahora.hour > hora) return true;
    if (ahora.hour == hora && ahora.minute > minuto) return true;

    return false;
  }

  /// Cambia el estado de una tarea a "Finalizada" y recarga la lista
  Future<void> _marcarComoFinalizada(Tarea tarea) async {
    // Evitamos actualizar si ya está finalizada
    if (tarea.estado.toLowerCase() == 'finalizada') return;

    // Creamos una nueva instancia con el estado actualizado
    final tareaActualizada = tarea.copyWith(estado: 'Finalizada');

    // Agregamos un registro para depuración
    debugPrint(
      'Actualizando tarea: ${tarea.id}, Estado: ${tarea.estado} -> Finalizada',
    );

    // Actualizamos en la base de datos
    await _dbHelper.actualizarEstadoTarea(tareaActualizada);

    // Recargamos la lista
    setState(() {
      _cargarTareas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tareas del ${widget.nombreDia}')),
      body: FutureBuilder<List<Tarea>>(
        future: _tareasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar las tareas'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay tareas para este día'));
          }

          final tareas = snapshot.data!;

          return ListView.builder(
            itemCount: tareas.length,
            itemBuilder: (context, index) {
              final tarea = tareas[index];
              return TaskTile(
                tarea: tarea,
                onTap: () async {
                  final relaciones = await _dbHelper.getRelacionesTarea(tarea.id);
                  if (relaciones.isNotEmpty) {
                    final tareaDia = relaciones.first; // Por ahora usamos la primera coincidencia
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleTareaScreen(
                            tarea: tarea,
                            tareaDia: tareaDia,
                          ),
                        ),
                      );
                    }
                  } else {
                    debugPrint('⚠️ No se encontró relación tarea-dia para la tarea ${tarea.titulo}');
                  }
                },
                onEstadoTap: () => _marcarComoFinalizada(tarea),
              );
            },
          );
        },
      ),
    );
  }
}
