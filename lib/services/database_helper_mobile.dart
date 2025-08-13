import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/observation.dart';
import 'database_helper_interface.dart';

class DatabaseHelperImpl implements DatabaseHelperInterface {
  static Database? _database;
  static bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    
    // Initialize FFI for mobile/desktop
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    _initialized = true;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('observations.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE observations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        species_name TEXT NOT NULL,
        species_type INTEGER NOT NULL,
        location TEXT,
        date TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        description TEXT,
        photo TEXT,
        conservation_status INTEGER NOT NULL,
        habitat_type INTEGER NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_species_type ON observations(species_type);');
    await db.execute('CREATE INDEX idx_conservation_status ON observations(conservation_status);');
  }

  @override
  Future<int> insertObservation(Observation obs) async {
    final db = await database;
    return await db.insert('observations', obs.toMap());
  }

  @override
  Future<List<Observation>> getObservations() async {
    final db = await database;
    final result = await db.query('observations', orderBy: 'date DESC');
    return result.map((map) => Observation.fromMap(map)).toList();
  }

  @override
  Future<int> updateObservation(Observation obs) async {
    final db = await database;
    return await db.update(
      'observations',
      obs.toMap(),
      where: 'id = ?',
      whereArgs: [obs.id],
    );
  }

  @override
  Future<int> deleteObservation(int id) async {
    final db = await database;
    return await db.delete(
      'observations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
} 