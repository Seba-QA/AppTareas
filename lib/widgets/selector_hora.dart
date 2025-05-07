import 'package:flutter/material.dart';

class SelectorHoraGroup extends StatelessWidget {
  final List<String> diasSeleccionados;
  final Map<String, TimeOfDay?> horaInicio;
  final Map<String, TimeOfDay?> horaTermino;

  const SelectorHoraGroup({
    super.key,
    required this.diasSeleccionados,
    required this.horaInicio,
    required this.horaTermino,
  });

  String _nombreDiaDesdeId(int id) {
    const nombres = {
      1: 'Lunes',
      2: 'Martes',
      3: 'Miércoles',
      4: 'Jueves',
      5: 'Viernes',
      6: 'Sábado',
      7: 'Domingo',
    };
    return nombres[id] ?? 'Día $id';
  }

  Future<void> _seleccionarHora(
    BuildContext context,
    String dia,
    bool esInicio,
  ) async {
    final horaActual =
        esInicio
            ? horaInicio[dia] ?? TimeOfDay.now()
            : horaTermino[dia] ?? TimeOfDay.now();

    final horaSeleccionada = await showTimePicker(
      context: context,
      initialTime: horaActual,
    );

    if (horaSeleccionada != null) {
      final map = esInicio ? horaInicio : horaTermino;
      map[dia] = horaSeleccionada;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          diasSeleccionados.map((dia) {
            final inicio = horaInicio[dia];
            final termino = horaTermino[dia];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_nombreDiaDesdeId(int.tryParse(dia) ?? 0)),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _seleccionarHora(context, dia, true),
                        child: Text(
                          'Inicio: ${inicio?.format(context) ?? '--:--'}',
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () => _seleccionarHora(context, dia, false),
                        child: Text(
                          'Término: ${termino?.format(context) ?? '--:--'}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
