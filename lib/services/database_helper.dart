import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/movie.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('movies.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();

    final dbFullPath = p.join(dbPath, filePath);


    final dir = Directory(p.dirname(dbFullPath));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return await openDatabase(
      dbFullPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE movies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        year INTEGER NOT NULL,
        genre TEXT NOT NULL,
        image_path TEXT
      )
    ''');
  }

  Future<int> createMovie(Movie movie) async {
    final db = await database;
    return await db.insert('movies', movie.toMap());
  }

  Future<List<Movie>> getMovies() async {
    final db = await database;
    final result = await db.query('movies', orderBy: 'id DESC');
    return result.map((json) => Movie.fromMap(json)).toList();
  }

  Future<int> updateMovie(Movie movie) async {
    final db = await database;
    return await db.update(
      'movies',
      movie.toMap(),
      where: 'id = ?',
      whereArgs: [movie.id],
    );
  }

  Future<int> deleteMovie(int id) async {
    final db = await database;
    return await db.delete(
      'movies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}