import 'package:apptareas/screens/agregar_tarea_screen.dart';
import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/dia_semana.dart';
import '../screens/lista_tareas_dia_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Clase local para juntar el nombre del día con la cantidad de tareas
class DiaConCantidad {
  final DiaSemana dia;
  final int cantidad;

  DiaConCantidad({required this.dia, required this.cantidad});
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<List<DiaConCantidad>> _diasConCantidadFuture; // Ahora trabajamos con esta nueva estructura

  @override
  void initState() {
    super.initState();
    _dbHelper.insertarDiasSemanaInicial(); // Aseguramos que existan los días
    _cargarDiasConCantidad(); // Cargar días + cantidad de tareas
  }

  /// Carga todos los días de la semana y la cantidad de tareas asociadas a cada uno
  void _cargarDiasConCantidad() {
    _diasConCantidadFuture = _obtenerDiasConCantidad();
  }

  /// Recorre los días y consulta cuántas tareas hay por cada uno
  Future<List<DiaConCantidad>> _obtenerDiasConCantidad() async {
    final dias = await _dbHelper.getDiasSemana();
    final List<DiaConCantidad> lista = [];

    for (final dia in dias) {
      final cantidad = await _dbHelper.getCantidadTareasPorDia(dia.id);
      lista.add(DiaConCantidad(dia: dia, cantidad: cantidad));
    }

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Días de la Semana'),
      ),
      body: FutureBuilder<List<DiaConCantidad>>(
        future: _diasConCantidadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los días'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay días cargados'));
          }

          final dias = snapshot.data!;

          return ListView.builder(
            itemCount: dias.length,
            itemBuilder: (context, index) {
              final item = dias[index];
              final nombreDia = item.dia.nombreDia;
              final cantidad = item.cantidad;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  // Mostramos el nombre alineado a la izquierda y la cantidad a la derecha
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(nombreDia),
                      Text(
                        cantidad > 0 ? '$cantidad ${cantidad == 1 ? 'tarea' : 'tareas'}' : 'Sin tareas',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListaTareasDiaScreen(
                          diaSemanaId: item.dia.id,
                          nombreDia: item.dia.nombreDia,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AgregarTareaScreen(),
            ),
          );

          if (resultado == true) {
            setState(() {
              _cargarDiasConCantidad(); // Volver a cargar tareas por día tras agregar
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
