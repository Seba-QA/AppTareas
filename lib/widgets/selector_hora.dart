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

  Future<void> _seleccionarHora(BuildContext context, String dia, bool esInicio) async {
    final horaActual = esInicio
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
      children: diasSeleccionados.map((dia) {
        final inicio = horaInicio[dia];
        final termino = horaTermino[dia];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dia,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
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
