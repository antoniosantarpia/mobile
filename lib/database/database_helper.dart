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
      onOpen: (db) async{
        await db.execute ('PRAGMA foreign_keys = ON;');
      },
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
        FOREIGN KEY(destinazione) REFERENCES destinazione(nome) ON DELETE NO ACTION
      );
    ''');

    await db.execute('''
      CREATE TABLE foto(
        id_foto INTEGER PRIMARY KEY, 
        viaggio INTEGER NOT NULL,
        path TEXT NOT NULL, 
        FOREIGN KEY(viaggio) REFERENCES viaggio(id_viaggio) ON DELETE CASCADE
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
        FOREIGN KEY(viaggio) REFERENCES viaggio(id_viaggio) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE categoria(
        nome VARCHAR(20) PRIMARY KEY
      );
    ''');

    await db.execute('''
      CREATE TABLE viaggio_categoria(
        categoria VARCHAR(20), 
        viaggio INTEGER, 
        PRIMARY KEY(categoria, viaggio), 
        FOREIGN KEY(categoria) REFERENCES categoria(nome) ON DELETE CASCADE, 
        FOREIGN KEY(viaggio) REFERENCES viaggio(id_viaggio) ON DELETE CASCADE
      );
    ''');
  }

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

  Future<int> insertDestinazione(destinazione destinazione) async {
    final db = await database;
    final newNome = destinazione.nome;

    final existingDestination = await db.rawQuery('''
        SELECT nome
        FROM destinazione d
        WHERE LOWER(d.nome) = LOWER(?)''', [newNome]); // Usa un segnaposto per evitare l'iniezione SQL

    if (existingDestination.isEmpty) {
      await db.insert(
        'destinazione',
        destinazione.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return 0;
    } else {
      return 1;
    }
  }



  Future<void> insertRecensione(recensione recensione) async {
    final db = await database;
    await db.insert(
      'recensione',
      recensione.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertCategoria(categoria categoria) async {
    final db = await database;
    final newNome = categoria.nome;

    final existingCategory = await db.rawQuery('''
        SELECT nome
        FROM categoria c
        WHERE LOWER(c.nome) = LOWER(?)''', [newNome]);

    if(existingCategory.isEmpty){
      await db.insert(
        'categoria',
        categoria.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return 0;
    } else {
      return 1;
    }
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

  Future<List<categoria>> getCategory() async {
    final db = await database;
    final List<Map<String, Object?>> maps = await db.query('categoria');

    return List.generate(maps.length, (i) {
      return categoria(
        nome: maps[i]['nome'] as String
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

  Future<void> deleteViaggioCategorieByViaggioId(int id) async {
    final db = await database;

    await db.delete(
      'viaggio_categoria',
      where: 'viaggio = ?',
      whereArgs: [id],
    );

  }


  Future<List<viaggio>> getViaggi() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('viaggio');

    return List.generate(maps.length, (i) {
      return viaggio.fromMap(maps[i]);
    });
  }

  Future<List<categoria>> getCategoryOfTrip(int id) async{
    try {
      final db = await database;
      final List<Map<String, Object?>> maps = await db.rawQuery('''
      SELECT categoria
      FROM viaggio_categoria vc
      WHERE vc.viaggio = $id
    ''');

      return List.generate(maps.length, (i) {
        return categoria(
          nome: maps[i]['categoria'] as String,
        );
      });
    }catch(e){
      print('Errore getCategoryOfTrip (con id=$id): $e');
      return [];
    }
  }

  Future<List<viaggio_categoria>> getViaggioCategoria() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('viaggio_categoria');

    return List.generate(maps.length, (i) {
      return viaggio_categoria.fromMap(maps[i]);
    });
  }


  Future<int> getLastViaggioId() async {
    final db = await database;
    var result = await db.rawQuery('SELECT MAX(id_viaggio) as max_id FROM viaggio');
    int? id = result.first['max_id'] as int?;
    return id ?? 0;  // Se il valore è null, restituisce 0
  }

  Future<int> getLastImgId() async {
    final db = await database;
    var result = await db.rawQuery('SELECT MAX(id_foto) as max_id FROM foto');
    int? id = result.first['max_id'] as int?;
    return id ?? 0;  // Se il valore è null, restituisce 0
  }

  Future<List<destinazione>> getUltimiViaggiDestinazioni(int limit) async {
    final db = await database;
    DateTime now = DateTime.now();
    final List<Map<String, Object?>> maps = await db.rawQuery('''
    SELECT d.nome, COUNT(v.id_viaggio) as trip_count
    FROM destinazione d
    JOIN viaggio v ON d.nome = v.destinazione
    WHERE v.data_fine < date('$now')
    GROUP BY d.nome
    ORDER BY MAX(v.data_fine) DESC
    LIMIT $limit
  ''');

    return List.generate(maps.length, (i) {
      return destinazione(
        nome: maps[i]['nome'] as String,
        tripCount: maps[i]['trip_count'] as int,
      );
    });
  }

  Future<void> updateViaggio(viaggio v) async {
    final db = await database;
    await db.update(
      'viaggio',
      v.toMap(),
      where: 'id_viaggio = ?',
      whereArgs: [v.id_viaggio],
    );
  }

  Future<void> saveOrUpdateFoto(foto f) async {
    final db = await database;

    // contrlla se la foto esiste
    final List<Map<String, dynamic>> maps = await db.query(
      'foto',
      where: 'id_foto = ?',
      whereArgs: [f.id_foto],
    );

    // aggiorna se esiste
    if (maps.isNotEmpty) {
      // Foto exists, update it
      await db.update(
        'foto',
        f.toMap(),
        where: 'id_foto = ?',
        whereArgs: [f.id_foto],
      );
    } else {
      // la foto non esiste quindi inseriscila
    insertFoto(f);
    }
  }

// Metodo per ottenere i dati dei viaggi per il grafico
  Future<List<Map<String, dynamic>>> getTripDataForChart() async {
    final db = await database;
    final DateTime now = DateTime.now();

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT 
      strftime('%Y-%m', data_inizio) as month_year, 
      COUNT(*) as count
    FROM viaggio
    WHERE data_fine IS NOT NULL
      AND data_fine <= '${now.toIso8601String()}'
    GROUP BY strftime('%Y-%m', data_inizio)
    ORDER BY strftime('%Y-%m', data_inizio) ASC
  ''');

    return maps;
  }

  Future<void> UpdateRecensione(recensione r) async {
    final db = await database;

    // verifica se la recensione esiste
    final List<Map<String, dynamic>> maps = await db.query(
      'recensione',
      where: 'id_recensione = ?',
      whereArgs: [r.id_recensione],
    );

    // aggiorna la recensione se esiste
    if (maps.isNotEmpty) {
      await db.update(
        'recensione',
        r.toMap(),
        where: 'id_recensione = ?',
        whereArgs: [r.id_recensione],
      );
    } else {
      throw Exception('Recensione non trovata'); // Lancia un'eccezione se la recensione non esiste
    }
  }



  Future<void> deleteViaggio(int id) async {
    final db = await database;
    await db.delete(
      'viaggio',
      where: 'id_viaggio = ?',
      whereArgs: [id],
    );
  }


  Future<void> deleteFoto(String path) async {
    final db = await database;
    await db.delete(
      'foto',
      where: 'path = ?',
      whereArgs: [path],
    );
  }



Future<int> getIdFoto(String path) async{
  final db = await instance.database;
  final maps = await db.query(
    'foto',
    where: 'path = ?',
    whereArgs: [path],
  );
  return foto.fromMap(maps.first).id_foto;
}

  Future<List<foto>> getFotoByViaggioId(int viaggio) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'foto',
      where: 'viaggio = ?',
      whereArgs: [viaggio],
    );
    return List.generate(maps.length, (i) {
      return foto.fromMap(maps[i]);
    });
  }

  Future<int?> getPhotoId() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT MAX(id_foto) as id FROM foto');
    int? lastPhotoId = Sqflite.firstIntValue(result);
    return lastPhotoId;
  }

  Future<int> getTotalTripsDone() async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT COUNT(*) as count 
    FROM viaggio v
    WHERE v.data_fine < date('now')''');
    int? id = result.first['count'] as int?;
    return id ?? 0;
  }

  Future<List<Map<String, dynamic>>> getMostVisitedDestinations() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT destinazione, COUNT(destinazione) AS count
      FROM viaggio v
      WHERE v.data_fine < date('now')
      GROUP BY destinazione
      ORDER BY count DESC
      LIMIT 3
    ''');
    return result;
  }

  Future<int> getLastRecId() async{
    final db = await database;
    var result = await db.rawQuery('SELECT MAX(id_recensione) as max_id FROM recensione');
    int? id = result.first['max_id'] as int?;
    return id ?? 0;  // Se il valore è null, restituisce 0
  }

  Future<String?> getRecensione(int idViaggio) async{
    final db = await database;
    var result = await db.rawQuery('SELECT testo FROM recensione r WHERE r.viaggio=$idViaggio');
    return result.first['testo'] as String?;
  }

  Future<int> getRecIdByViaggio(int idViaggio) async{
    final db = await database;
    final result = await db.rawQuery('''
      SELECT id_recensione
      FROM recensione
      WHERE viaggio = $idViaggio
    ''');
    if (result.isNotEmpty) {
      return (result.first['id_recensione'] as int?) ?? 0; // Restituisci 0 se il valore è nullo
    } else {
      return 0; // Restituisci 0 se non ci sono risultati
    }
  }

  Future<int> verifyDateTrip(String dataInizio, String dataFine) async{
    final db = await database;
    final result = await db.rawQuery('''
      SELECT *
      FROM viaggio v
      WHERE 
    ''');
    if (result.isNotEmpty) {
      return (result.first['id_recensione'] as int?) ?? 0; // Restituisci 0 se il valore è nullo
    } else {
      return 0; // Restituisci 0 se non ci sono risultati
    }

  }

  Future<int> verifyCategory(categoria c) async{
    final db = await database;
    final nomeCat = c.nome;
    final result = await db.rawQuery('''
       SELECT count(*) as c
      FROM viaggio_categoria vc 
      WHERE vc.categoria = ?
      ''', [nomeCat]);

    int? id = result.first['c'] as int?;
    return id ?? 0;
  }

  Future<void> deleteReview(int idViaggio) async{
    final db = await database;
    await db.delete(
      'recensione',
      where: 'viaggio = ?',
      whereArgs: [idViaggio],
    );
  }

  Future<void> deleteCategory(categoria c) async{
    final db = await database;
    final nomeCat = c.nome;
    await db.delete(
      'categoria',
      where: 'nome = ?',
      whereArgs: [nomeCat],
    );
  }


  }



