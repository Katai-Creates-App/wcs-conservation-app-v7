import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/observation.dart';
import 'observation_storage_service.dart';

class MobileStorageService implements ObservationStorageService {
  static Database? _database;
  static bool _initialized = false;

  @override
  Future<void> initialize() async {
    print('MobileStorageService.initialize: Starting mobile storage initialization');
    if (_initialized) {
      print('MobileStorageService.initialize: Already initialized, returning early');
      return;
    }
    
    try {
      print('MobileStorageService.initialize: Initializing FFI for mobile/desktop');
      // Initialize FFI for mobile/desktop
      _initialized = true;
      print('MobileStorageService.initialize: Mobile storage initialization completed successfully');
    } catch (e, stackTrace) {
      print('MobileStorageService.initialize: ERROR in mobile storage initialization: $e');
      print('MobileStorageService.initialize: Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Database> get database async {
    print('MobileStorageService.database: Getting database instance');
    if (_database != null) {
      print('MobileStorageService.database: Returning existing database instance');
      return _database!;
    }
    print('MobileStorageService.database: Creating new database instance');
    _database = await _initDB('observations.db');
    print('MobileStorageService.database: Database instance created successfully');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    print('MobileStorageService._initDB: Initializing database with file: $filePath');
    try {
      final dbPath = await getDatabasesPath();
      print('MobileStorageService._initDB: Database path: $dbPath');
      final path = join(dbPath, filePath);
      print('MobileStorageService._initDB: Full database path: $path');
      
      final database = await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
      print('MobileStorageService._initDB: Database opened successfully');
      return database;
    } catch (e, stackTrace) {
      print('MobileStorageService._initDB: ERROR opening database: $e');
      print('MobileStorageService._initDB: Stack trace: $stackTrace');
      rethrow;
    }
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
  Future<int> insert(Observation observation) async {
    final db = await database;
    return await db.insert('observations', observation.toMap());
  }

  @override
  Future<List<Observation>> getAll() async {
    final db = await database;
    final result = await db.query('observations', orderBy: 'date DESC');
    return result.map((map) => Observation.fromMap(map)).toList();
  }

  @override
  Future<int> update(Observation observation) async {
    final db = await database;
    return await db.update(
      'observations',
      observation.toMap(),
      where: 'id = ?',
      whereArgs: [observation.id],
    );
  }

  @override
  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      'observations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('observations');
  }
} 