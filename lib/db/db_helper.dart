import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/tarea.dart'; // Tu modelo de Tarea
import '../models/dia_semana.dart'; // Tu modelo de Día de la Semana
import '../models/tarea_dia.dart'; // Tu modelo de Tarea-Día

/// Clase que maneja la conexión y creación de la base de datos local SQLite
class DatabaseHelper {
  // Creamos una única instancia de esta clase (Singleton Pattern)
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Método fábrica para devolver siempre la misma instancia
  factory DatabaseHelper() {
    return _instance;
  }

  // Constructor privado
  DatabaseHelper._internal();

  /// Getter para acceder a la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa la base de datos
  Future<Database> _initDatabase() async {
    // Obtenemos la ruta donde se almacenan las bases de datos en el dispositivo
    final dbPath = await getDatabasesPath();
    final path = join(
      dbPath,
      'rutinas.db',
    ); // Definimos el nombre de nuestra BD

    // Abrimos (o creamos) la base de datos
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  /// Método que se ejecuta SOLO cuando la base de datos se crea por primera vez
  /// Aquí se crean todas las tablas necesarias
  Future<void> _onCreate(Database db, int version) async {
    // Crear tabla 'dias_semana' que contendrá los nombres de los días (Lunes, Martes, etc.)
    await db.execute('''
      CREATE TABLE dias_semana (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombreDia TEXT NOT NULL,
        dia_id INTEGER
      )
    ''');

    // Crear tabla 'tareas' que guarda la información general de cada tarea
    await db.execute('''
      CREATE TABLE tareas (
        id TEXT PRIMARY KEY,
        titulo TEXT NOT NULL,
        descripcion TEXT,
        etiqueta TEXT,
        estado TEXT NOT NULL,
        prioridad TEXT NOT NULL,
        notificacion INTEGER NOT NULL
      )
    ''');

    // Crear tabla 'tarea_dia' que relaciona una tarea con uno o más días
    // Además almacena los horarios específicos para cada día
    await db.execute('''
      CREATE TABLE tarea_dia (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tareaId TEXT NOT NULL,
        diaSemanaId INTEGER NOT NULL,
        horaInicio TEXT NOT NULL,
        horaTermino TEXT NOT NULL
      )
    ''');
  }

  /// ------------------------------
  /// MÉTODOS DE INSERCIÓN (CREATE)
  /// ------------------------------

  /// Inserta una nueva tarea en la base de datos
  Future<void> insertTarea(Tarea tarea) async {
    final db = await database;
    await db.insert(
      'tareas',
      tarea.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Inserta un nuevo día de la semana en la base de datos
  Future<void> insertarDiasSemanaInicial() async {
    final db = await database;

    // Consulta si ya hay días insertados
    final List<Map<String, dynamic>> existingDias = await db.query(
      'dias_semana',
    );

    if (existingDias.isEmpty) {
      // Si no hay, los insertamos
      List<String> dias = [
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
        'Domingo',
      ];
      for (var dia in dias) {
        await db.insert('dias_semana', {'nombreDia': dia});
      }
    }
  }

  /// Inserta una nueva relación Tarea-Día en la base de datos
  Future<void> insertTareaDia(TareaDia tareaDia) async {
    final db = await database;
    await db.insert(
      'tarea_dia',
      tareaDia.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// ------------------------------
  /// MÉTODOS DE LECTURA (READ)
  /// ------------------------------

  /// Obtener todas las tareas
  Future<List<Tarea>> getTareas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tareas');

    return List.generate(maps.length, (i) {
      return Tarea.fromMap(maps[i]);
    });
  }

  /// Obtener todos los días de la semana
  Future<List<DiaSemana>> getDiasSemana() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('dias_semana');

    return List.generate(maps.length, (i) {
      return DiaSemana.fromMap(maps[i]);
    });
  }

  /// Obtener todas las relaciones tarea-dia
  Future<List<TareaDia>> getTareasDia() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tarea_dia');

    return List.generate(maps.length, (i) {
      return TareaDia.fromMap(maps[i]);
    });
  }

  Future<List<TareaDia>> getTareaDiaPorTareaId(String tareaId) async {
    final db = await database;
    final maps = await db.query(
      'tarea_dia',
      where: 'tareaId = ?', // Corregido el nombre de la columna
      whereArgs: [tareaId],
    );
    return maps.map((map) => TareaDia.fromMap(map)).toList();
  }

  /// Obtener todas las tareas de un día específico
  Future<List<Tarea>> getTareasPorDia(int diaSemanaId) async {
    final db = await database;

    // Hacemos una consulta uniendo tareas y tarea_dia
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
        SELECT tareas.* FROM tareas
        INNER JOIN tarea_dia ON tareas.id = tarea_dia.tareaId
        WHERE tarea_dia.diaSemanaId = ?
      ''',
      [diaSemanaId],
    );

    return List.generate(maps.length, (i) {
      return Tarea.fromMap(maps[i]);
    });
  }

  /// Obtener todas las relaciones tarea_dia para una tarea específica
  Future<List<TareaDia>> getRelacionesTarea(String tareaId) async {
    final db = await database;
    final maps = await db.query(
      'tarea_dia',
      where: 'tareaId = ?',
      whereArgs: [tareaId],
    );

    return maps.map((mapa) => TareaDia.fromMap(mapa)).toList();
  }

  /// Obtener la cantidad de tareas asociadas a un día específico
  Future<int> getCantidadTareasPorDia(int diaId) async {
    final db = await database;

    // Consulta que cuenta las tareas relacionadas al día
    final result = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM tarea_dia WHERE diaSemanaId = ?',
        [diaId],
      ),
    );

    // Si no encuentra resultados, devuelve 0 por defecto
    return result ?? 0;
  }

  /// ------------------------------
  /// MÉTODOS DE ACTUALIZACIÓN (UPDATE)
  /// ------------------------------

  /// Actualizar una tarea existente
  Future<void> updateTarea(Tarea tarea) async {
    final db = await database;
    await db.update(
      'tareas',
      tarea.toMap(),
      where: 'id = ?',
      whereArgs: [tarea.id],
    );
  }

  /// Actualizar la asignación de una tarea a un día
  Future<void> updateTareaDia(TareaDia tareaDia) async {
    final db = await database;

    await db.update(
      'tarea_dia',
      tareaDia.toMap(), // Convertimos el objeto TareaDia a Map
      where: 'id = ?', // Indicamos qué relación actualizar
      whereArgs: [tareaDia.id], // El ID de la relación
    );
  }

  Future<void> actualizarEstadoTarea(Tarea tarea) async {
    final db = await database;
    await db.update(
      'tareas',
      {'estado': tarea.estado},
      where: 'id = ?',
      whereArgs: [tarea.id],
    );
  }

  /// ------------------------------
  /// MÉTODOS DE ELIMINACIÓN (DELETE)
  /// ------------------------------

  /// Eliminar una tarea por su ID
  Future<void> deleteTarea(String id) async {
    final db = await database;

    await db.delete(
      'tareas',
      where: 'id = ?', // Condición
      whereArgs: [id], // Valor
    );
  }

  /// Eliminar una relación tarea-día por su ID
  Future<void> deleteTareaDia(int id) async {
    final db = await database;

    await db.delete(
      'tarea_dia',
      where: 'id = ?', // Condición
      whereArgs: [id], // Valor
    );
  }

  Future<void> deleteRelacionesTarea(String tareaId) async {
    final db = await database;
    await db.delete(
      'tarea_dia',
      where: 'tareaId = ?',
      whereArgs: [tareaId],
    );
  }

}
