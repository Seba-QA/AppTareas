import 'package:flutter/material.dart';

class DiaCheckboxGroup extends StatelessWidget {
  final List<String> dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  final List<String> diasSeleccionados;
  final Function(String) onSeleccionChanged;

  DiaCheckboxGroup({
    super.key,
    required this.diasSeleccionados,
    required this.onSeleccionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Días de la semana:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          children: dias.map((dia) {
            final seleccionado = diasSeleccionados.contains(dia);
            return FilterChip(
              label: Text(dia),
              selected: seleccionado,
              onSelected: (_) => onSeleccionChanged(dia),
            );
          }).toList(),
        ),
      ],
    );
  }
}
