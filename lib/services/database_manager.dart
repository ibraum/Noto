import 'package:Noto/models/utilisateur.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class DatabaseManager {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initializeDB();
    return _db!;
  }

  Future<Database> _initializeDB() async {
    var databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'gestion.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT NOT NULL,
            priorite TEXT NOT NULL,
            dateDebut TEXT,
            dateFin TEXT,
            progression INTEGER NOT NULL
          )
        ''');

        await db.execute('''
        CREATE TABLE utilisateurs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nom TEXT NOT NULL UNIQUE,
          mot_de_passe TEXT NOT NULL
        )
      ''');

        await db.insert('utilisateurs', {
          'nom': 'admin',
          'mot_de_passe': 'admin123',
        });
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
          CREATE TABLE utilisateurs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nom TEXT NOT NULL UNIQUE,
            mot_de_passe TEXT NOT NULL
          )
        ''');

          await db.insert('utilisateurs', {
            'nom': 'admin',
            'mot_de_passe': 'admin123',
          });
        }
      },
    );
  }

  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final result = await db.query('notes');
    return result.map((e) => Note.fromMap(e)).toList();
  }

  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<int> updateNote(Note note, int? id) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteNote(int? id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<Utilisateur?> getUtilisateur(String nom, String motDePasse) async {
    final db = await database;
    final result = await db.query(
      'utilisateurs',
      where: 'nom = ? AND mot_de_passe = ?',
      whereArgs: [nom, motDePasse],
    );
    if (result.isNotEmpty) {
      return Utilisateur.fromMap(result.first);
    }
    return null;
  }

  Future<int> insertUtilisateur(Utilisateur utilisateur) async {
    final db = await database;
    return await db.insert('utilisateurs', utilisateur.toMap());
  }
}
