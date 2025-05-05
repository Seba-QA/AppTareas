import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../db/db_helper.dart';
import '../models/tarea.dart';
import '../models/tarea_dia.dart';
import '../widgets/dia_checkbox.dart';
import '../widgets/selector_hora.dart';

class EditarTareaScreen extends StatefulWidget {
  final Tarea tarea;

  const EditarTareaScreen({super.key, required this.tarea});

  @override
  State<EditarTareaScreen> createState() => _EditarTareaScreenState();
}

class _EditarTareaScreenState extends State<EditarTareaScreen> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final List<String> _diasSeleccionados = [];
  final Map<String, TimeOfDay?> _horaInicio = {};
  final Map<String, TimeOfDay?> _horaTermino = {};

  String _etiqueta = 'Personal';
  String _prioridad = 'Baja';

  @override
  void initState() {
    super.initState();

    // Precargamos los datos de la tarea a editar
    _tituloController.text = widget.tarea.titulo;
    _descripcionController.text = widget.tarea.descripcion;
    _etiqueta = widget.tarea.etiqueta;
    _prioridad = widget.tarea.prioridad;

    _cargarRelacionesTarea(widget.tarea.id);
  }

  // Cargar días y horas relacionados a la tarea
  void _cargarRelacionesTarea(String tareaId) async {
    final relaciones = await _dbHelper.getRelacionesTarea(tareaId);

    for (var relacion in relaciones) {
      _diasSeleccionados.add(relacion.diaSemanaId.toString());

      final partesInicio = relacion.horaInicio.split(':');
      final partesTermino = relacion.horaTermino.split(':');

      _horaInicio[relacion.diaSemanaId.toString()] = TimeOfDay(
        hour: int.tryParse(partesInicio[0]) ?? 0,
        minute: int.tryParse(partesInicio[1]) ?? 0,
      );

      _horaTermino[relacion.diaSemanaId.toString()] = TimeOfDay(
        hour: int.tryParse(partesTermino[0]) ?? 0,
        minute: int.tryParse(partesTermino[1]) ?? 0,
      );
    }

    setState(() {});
  }

  // Guardar los cambios en la tarea
  void _guardarCambios() async {
    final tareaActualizada = widget.tarea.copyWith(
      titulo: _tituloController.text,
      descripcion: _descripcionController.text,
      etiqueta: _etiqueta,
      prioridad: _prioridad,
    );

    await _dbHelper.updateTarea(tareaActualizada);
    await _dbHelper.deleteRelacionesTarea(widget.tarea.id);

    for (var dia in _diasSeleccionados) {
      final inicio = _horaInicio[dia];
      final termino = _horaTermino[dia];

      if (inicio != null && termino != null) {
        final relacion = TareaDia(
        tareaId: widget.tarea.id,
        diaSemanaId: int.parse(dia), // ✅ Convertimos el String a int
        horaInicio: '${inicio.hour}:${inicio.minute.toString().padLeft(2, '0')}',
        horaTermino: '${termino.hour}:${termino.minute.toString().padLeft(2, '0')}',
      );
        await _dbHelper.insertTareaDia(relacion);
      }
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar tarea'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 16),
              const Text('Etiqueta:'),
              DropdownButton<String>(
                value: _etiqueta,
                items: ['Personal', 'Trabajo', 'Estudio']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => _etiqueta = value!),
              ),
              const SizedBox(height: 16),
              const Text('Prioridad:'),
              DropdownButton<String>(
                value: _prioridad,
                items: ['Alta', 'Media', 'Baja']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => _prioridad = value!),
              ),
              const SizedBox(height: 16),
              DiaCheckboxGroup(
                diasSeleccionados: _diasSeleccionados,
                onSeleccionChanged: (nuevoDia) {
                  setState(() {
                    if (_diasSeleccionados.contains(nuevoDia)) {
                      _diasSeleccionados.remove(nuevoDia);
                    } else {
                      _diasSeleccionados.add(nuevoDia);
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              SelectorHoraGroup(
                diasSeleccionados: _diasSeleccionados,
                horaInicio: _horaInicio,
                horaTermino: _horaTermino,
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _guardarCambios,
                  child: const Text('Confirmar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
