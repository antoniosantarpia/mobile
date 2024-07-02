import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'viaggio.dart';
import 'categoria.dart';
import 'recensione.dart';
import 'destinazione.dart';
import 'foto.dart';
import 'viaggio_categoria.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'miodatabase.db'),
      onCreate: _createTables,
      version: 1,
    );
  }


  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE viaggio(
        id_viaggio INTEGER PRIMARY KEY, 
        titolo VARCHAR(30) NOT NULL, 
        note TEXT,
        itinerario TEXT, 
        data_inizio DATE NOT NULL, 
        data_fine DATE NOT NULL, 
        destinazione VARCHAR(20) NOT NULL,
        FOREIGN KEY(destinazione) REFERENCES destinazione(nome)
      );
    ''');

    await db.execute('''
      CREATE TABLE foto(
        id_foto INTEGER PRIMARY KEY, 
        viaggio INTEGER NOT NULL, 
        FOREIGN KEY(viaggio) REFERENCES viaggio(id_viaggio)
      );
    ''');

    await db.execute('''
      CREATE TABLE destinazione(
        nome VARCHAR(20) PRIMARY KEY,
        tripCount INTEGER NOT NULL DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE recensione(
        id_recensione INTEGER PRIMARY KEY, 
        testo TEXT NOT NULL, 
        viaggio INTEGER NOT NULL, 
        FOREIGN KEY(viaggio) REFERENCES viaggio(id_viaggio)
      );
    ''');

    await db.execute('''
      CREATE TABLE categoria(
        id_categoria INTEGER PRIMARY KEY, 
        nome VARCHAR(20) NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE viaggio_categoria(
        categoria INTEGER, 
        viaggio INTEGER, 
        PRIMARY KEY(categoria, viaggio), 
        FOREIGN KEY(categoria) REFERENCES categoria(id_categoria), 
        FOREIGN KEY(viaggio) REFERENCES viaggio(id_viaggio)
      );
    ''');
  }

  // Funzioni di inserimento, recupero e cancellazione per le tabelle...

  Future<void> insertViaggio(viaggio viaggio) async {
    final db = await database;
    await db.insert(
      'viaggio',
      viaggio.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertFoto(foto foto) async {
    final db = await database;
    await db.insert(
      'foto',
      foto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertDestinazione(destinazione destinazione) async {
    final db = await database;

    await db.insert(
      'destinazione',
      destinazione.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> insertRecensione(recensione recensione) async {
    final db = await database;
    await db.insert(
      'recensione',
      recensione.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertCategoria(categoria categoria) async {
    final db = await database;
    await db.insert(
      'categoria',
      categoria.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertViaggioCategoria(viaggio_categoria viaggioCategoria) async {
    final db = await database;
    await db.insert(
      'viaggio_categoria',
      viaggioCategoria.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<destinazione>> getDestinations() async {
    final db = await database;
    final List<Map<String, Object?>> maps = await db.query('destinazione');

    return List.generate(maps.length, (i) {
      return destinazione(
        nome: maps[i]['nome'] as String,
        tripCount: maps[i]['tripCount'] as int,
      );
    });
  }

  Future<List<Map<String, dynamic>>> getDestinationWithTripCount() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT d.nome, COUNT(v.id_viaggio) as trip_count
      FROM destinazione d
      LEFT JOIN viaggio v ON d.nome = v.destinazione
      GROUP BY d.nome
    ''');
  }

  Future<int> getLastDestinazioneId() async {
    final db = await database;
    var result = await db.rawQuery('SELECT MAX(id_destinazione) as max_id FROM destinazione');
    int? id = result.first['max_id'] as int?;
    return id ?? 0;  // Se il valore è null, restituisce 0
  }

  Future<void> deleteDestinazione(String nome) async {
    final db = await database;
    await db.delete(
      'destinazione',
      where: 'nome = ?',
      whereArgs: [nome],
    );
  }

  Future<List<viaggio>> getViaggi() async {
    final db = await database;
    final List<Map<String, Object?>> maps = await db.rawQuery('''
    SELECT 
      v.id_viaggio,
      v.titolo,
      v.data_inizio,
      v.data_fine,
      v.note,
      v.itinerario,
      d.nome AS destinazione 
    FROM viaggio v
    JOIN destinazione d ON v.destinazione = d.nome
  ''');

    return List.generate(maps.length, (i) {
      return viaggio(
        id_viaggio: maps[i]['id_viaggio'] as int,
        titolo: maps[i]['titolo'] as String,
        data_inizio: DateTime.parse(maps[i]['data_inizio'] as String),
        data_fine: DateTime.parse(maps[i]['data_fine'] as String),
        note: maps[i]['note'] as String,
        itinerario: maps[i]['itinerario'] as String,
        destinazione: maps[i]['destinazione'] as String, // Usa il nome della destinazione recuperato dalla query
      );
    });
  }

  Future<int> getLastViaggioId() async {
    final db = await database;
    var result = await db.rawQuery('SELECT MAX(id_viaggio) as max_id FROM viaggio');
    int? id = result.first['max_id'] as int?;
    return id ?? 0;  // Se il valore è null, restituisce 0
  }

  Future<void> deleteViaggio(int id) async {
    final db = await database;
    await db.delete(
      'viaggio',
      where: 'id_viaggio = ?',
      whereArgs: [id],
    );
  }

}
