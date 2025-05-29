import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../db/db_helper.dart';
import '../models/tarea.dart';
import '../models/tarea_dia.dart';
import '../models/dia_semana.dart';
import '../utils/notificaciones_helper.dart';


class AgregarTareaScreen extends StatefulWidget {
  const AgregarTareaScreen({super.key});

  @override
  State<AgregarTareaScreen> createState() => _AgregarTareaScreenState();
}

class _AgregarTareaScreenState extends State<AgregarTareaScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _etiqueta = 'Sin etiqueta';
  String _prioridad = 'Baja';

  // Para manejar los días seleccionados
  List<int> _diasSeleccionados = [];

  // Para manejar los horarios
  bool _usarMismoHorario = true;
  TimeOfDay _horaInicioComun = TimeOfDay.now();
  TimeOfDay _horaTerminoComun = TimeOfDay.now();
  Map<int, TimeOfDay> _horaInicioPorDia = {};
  Map<int, TimeOfDay> _horaTerminoPorDia = {};

  late Future<List<DiaSemana>> _diasSemanaFuture;

  @override
  void initState() {
    super.initState();
    _diasSemanaFuture = _dbHelper.getDiasSemana();
  }

Future<void> _guardarTarea() async {
  if (_formKey.currentState!.validate() && _diasSeleccionados.isNotEmpty) {
    final idTarea = const Uuid().v4();

    final nuevaTarea = Tarea(
      id: idTarea,
      titulo: _tituloController.text,
      descripcion: _descripcionController.text,
      etiqueta: _etiqueta,
      estado: 'No comenzado',
      prioridad: _prioridad,
      notificacion: true,
    );

    await _dbHelper.insertTarea(nuevaTarea);

    // Insertar en tarea_dia para cada día seleccionado
    for (int diaId in _diasSeleccionados) {
      TimeOfDay? horaInicio;
      TimeOfDay? horaTermino;

      if (_usarMismoHorario) {
        horaInicio = _horaInicioComun;
        horaTermino = _horaTerminoComun;
      } else {
        horaInicio = _horaInicioPorDia[diaId];
        horaTermino = _horaTerminoPorDia[diaId];

        if (horaInicio == null || horaTermino == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Debes asignar horario a todos los días seleccionados')),
          );
          return; // Detenemos el guardado
        }
      }

      final nuevaRelacion = TareaDia(
        tareaId: idTarea,
        diaSemanaId: diaId,
        horaInicio: '${horaInicio.hour}:${horaInicio.minute}',
        horaTermino: '${horaTermino.hour}:${horaTermino.minute}',
      );

      await _dbHelper.insertTareaDia(nuevaRelacion);

      // === 🕑 NOTIFICACIONES ===

      final ahora = DateTime.now();
      final hoyDiaSemana = ahora.weekday; // 1 = lunes
      final diferenciaDias = diaId - hoyDiaSemana;
      final fechaTarea = ahora.add(Duration(days: diferenciaDias >= 0 ? diferenciaDias : diferenciaDias + 7));

      final inicioDateTime = DateTime(
        fechaTarea.year,
        fechaTarea.month,
        fechaTarea.day,
        horaInicio.hour,
        horaInicio.minute,
      ).subtract(const Duration(minutes: 5));

      final terminoDateTime = DateTime(
        fechaTarea.year,
        fechaTarea.month,
        fechaTarea.day,
        horaTermino.hour,
        horaTermino.minute,
      ).subtract(const Duration(minutes: 10));

      // ID base único para evitar colisiones
      final baseId = const Uuid().v4().hashCode;

      await NotificacionesHelper.programarNotificacion(
        id: baseId,
        titulo: '📌 Tarea próxima',
        cuerpo: 'Tarea "${nuevaTarea.titulo}" comienza pronto.',
        fechaHora: inicioDateTime,
      );

      await NotificacionesHelper.programarNotificacion(
        id: baseId + 1,
        titulo: '⚠️ No olvides tu tarea',
        cuerpo: 'Tarea "${nuevaTarea.titulo}" está por finalizar.',
        fechaHora: terminoDateTime,
      );
    }

    Navigator.pop(context, true); // Volver indicando éxito
  }
}


  Future<void> _seleccionarHoraInicioComun() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaInicioComun,
    );
    if (picked != null) {
      setState(() {
        _horaInicioComun = picked;
      });
    }
  }

  Future<void> _seleccionarHoraTerminoComun() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaTerminoComun,
    );
    if (picked != null) {
      setState(() {
        _horaTerminoComun = picked;
      });
    }
  }

  Future<void> _seleccionarHoraInicioPorDia(int diaId) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _horaInicioPorDia[diaId] = picked;
      });
    }
  }

  Future<void> _seleccionarHoraTerminoPorDia(int diaId) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _horaTerminoPorDia[diaId] = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar nueva tarea')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => value!.isEmpty ? 'Ingrese un título' : null,
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (value) => value!.isEmpty ? 'Ingrese una descripción' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Etiqueta (opcional)'),
                onChanged: (value) {
                  _etiqueta = value;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _prioridad,
                items: ['Baja', 'Media', 'Alta'].map((prioridad) {
                  return DropdownMenuItem(
                    value: prioridad,
                    child: Text(prioridad),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _prioridad = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Prioridad'),
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<DiaSemana>>(
                future: _diasSemanaFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final dias = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Seleccionar días:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...dias.map((dia) {
                        return CheckboxListTile(
                          title: Text(dia.nombreDia),
                          value: _diasSeleccionados.contains(dia.id),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                _diasSeleccionados.add(dia.id);
                              } else {
                                _diasSeleccionados.remove(dia.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('¿Usar mismo horario para todos los días?'),
                value: _usarMismoHorario,
                onChanged: (value) {
                  setState(() {
                    _usarMismoHorario = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              _usarMismoHorario
                  ? Column(
                      children: [
                        ListTile(
                          title: const Text('Hora de inicio'),
                          subtitle: Text(_horaInicioComun.format(context)),
                          onTap: _seleccionarHoraInicioComun,
                        ),
                        ListTile(
                          title: const Text('Hora de término'),
                          subtitle: Text(_horaTerminoComun.format(context)),
                          onTap: _seleccionarHoraTerminoComun,
                        ),
                      ],
                    )
                  : FutureBuilder<List<DiaSemana>>(
                      future: _diasSemanaFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        final dias = snapshot.data!;
                        final diasFiltrados = dias.where((d) => _diasSeleccionados.contains(d.id)).toList();

                        return Column(
                          children: diasFiltrados.map((dia) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(dia.nombreDia, style: const TextStyle(fontWeight: FontWeight.bold)),
                                ListTile(
                                  title: const Text('Hora de inicio'),
                                  subtitle: Text(_horaInicioPorDia[dia.id]?.format(context) ?? 'Seleccionar'),
                                  onTap: () => _seleccionarHoraInicioPorDia(dia.id),
                                ),
                                ListTile(
                                  title: const Text('Hora de término'),
                                  subtitle: Text(_horaTerminoPorDia[dia.id]?.format(context) ?? 'Seleccionar'),
                                  onTap: () => _seleccionarHoraTerminoPorDia(dia.id),
                                ),
                                const Divider(),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarTarea,
                child: const Text('Guardar tarea'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
