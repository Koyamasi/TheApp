import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'building_manager.db');
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onOpen: (db) {
          print('Database opened successfully');
        },
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future _onCreate(Database db, int version) async {
    try {
      // Buildings table
      await db.execute('''
        CREATE TABLE buildings (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          address TEXT NOT NULL,
          managerId TEXT NOT NULL
        )
      ''');
      print('Database tables created successfully');
    } catch (e) {
      print('Error creating database tables: $e');
      rethrow;
    }
  }

  // Building operations with error handling
  Future<int> insertBuilding(Map<String, dynamic> building) async {
    try {
      Database db = await database;
      return await db.insert('buildings', building);
    } catch (e) {
      print('Error inserting building: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getManagerBuildings(String managerId) async {
    try {
      Database db = await database;
      return await db.query(
        'buildings',
        where: 'managerId = ?',
        whereArgs: [managerId],
        orderBy: 'name ASC',
      );
    } catch (e) {
      print('Error getting manager buildings: $e');
      return [];
    }
  }
} 