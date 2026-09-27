import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/categoria.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('control_reparto.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE LC_categorias (
        id_categoria INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        color TEXT NOT NULL,
        indice INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE LC_productos (
        id_producto INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        precio REAL NOT NULL,
        es_contable INTEGER NOT NULL DEFAULT 1,
        indice INTEGER NOT NULL DEFAULT 0,
        id_categoria INTEGER NOT NULL,
        FOREIGN KEY (id_categoria) REFERENCES LC_categorias (id_categoria)
      )
    ''');

    await db.execute('''
      CREATE TABLE LC_repartidores (
        id_repartidor INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE LC_observadores (
        id_observador INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        pin TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE LC_reportes (
        id_reporte INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha TEXT NOT NULL,
        id_repartidor INTEGER NOT NULL,
        id_observador INTEGER NOT NULL,
        id_ultimo_editor INTEGER,
        fecha_ultima_edicion TEXT,
        FOREIGN KEY (id_repartidor) REFERENCES LC_repartidores (id_repartidor),
        FOREIGN KEY (id_observador) REFERENCES LC_observadores (id_observador),
        FOREIGN KEY (id_ultimo_editor) REFERENCES LC_observadores (id_observador)
      )
    ''');

    await db.execute('''
      CREATE TABLE LC_reporte_detalle (
        id_detalle INTEGER PRIMARY KEY AUTOINCREMENT,
        id_reporte INTEGER NOT NULL,
        id_producto INTEGER NOT NULL,
        cantidad_traia REAL NOT NULL DEFAULT 0,
        cantidad_cargo REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (id_reporte) REFERENCES LC_reportes (id_reporte),
        FOREIGN KEY (id_producto) REFERENCES LC_productos (id_producto)
      )
    ''');

    await _ensureCategoriaBase(db);
    await _normalizarIndicesCategorias(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.transaction((txn) async {
        await txn.execute('''
          CREATE TABLE LC_categorias (
            id_categoria INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            color TEXT NOT NULL,
            indice INTEGER NOT NULL DEFAULT 0
          )
        ''');

        final idCategoriaBase = await _ensureCategoriaBase(txn);

        await txn.execute('''
          CREATE TABLE LC_productos_nueva (
            id_producto INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            precio REAL NOT NULL,
            es_contable INTEGER NOT NULL DEFAULT 1,
            indice INTEGER NOT NULL DEFAULT 0,
            id_categoria INTEGER NOT NULL,
            FOREIGN KEY (id_categoria) REFERENCES LC_categorias (id_categoria)
          )
        ''');

        final productosActuales = await txn.query(
          'LC_productos',
          orderBy: 'nombre ASC',
        );

        var indice = 1;
        for (final producto in productosActuales) {
          await txn.insert('LC_productos_nueva', {
            'id_producto': producto['id_producto'],
            'nombre': producto['nombre'],
            'precio': producto['precio'],
            'es_contable': producto['es_contable'],
            'indice': indice,
            'id_categoria': idCategoriaBase,
          });
          indice++;
        }

        await txn.execute('DROP TABLE LC_productos');
        await txn.execute(
          'ALTER TABLE LC_productos_nueva RENAME TO LC_productos',
        );
        await _normalizarIndicesCategorias(txn);
      });
    }

    if (oldVersion >= 2 && oldVersion < 3) {
      await db.transaction((txn) async {
        await txn.execute(
          'ALTER TABLE LC_categorias ADD COLUMN indice INTEGER NOT NULL DEFAULT 0',
        );
        await _ensureCategoriaBase(txn);
        await _normalizarIndicesCategorias(txn);
      });
    }
  }

  Future<int> ensureCategoriaBase() async {
    final db = await database;
    await ensureCategoriaIndiceColumn(db);
    return _ensureCategoriaBase(db);
  }

  Future<int> _ensureCategoriaBase(DatabaseExecutor db) async {
    final existente = await db.query(
      'LC_categorias',
      where: 'LOWER(TRIM(nombre)) = ?',
      whereArgs: [Categoria.nombreBase.toLowerCase()],
      limit: 1,
    );

    if (existente.isNotEmpty) {
      final id = (existente.first['id_categoria'] as num).toInt();
      await db.update(
        'LC_categorias',
        {'nombre': Categoria.nombreBase, 'color': Categoria.colorBase},
        where: 'id_categoria = ?',
        whereArgs: [id],
      );
      return id;
    }

    return db.insert('LC_categorias', {
      'nombre': Categoria.nombreBase,
      'color': Categoria.colorBase,
      'indice': 0,
    });
  }

  Future<void> normalizarIndicesCategorias() async {
    final db = await database;
    await ensureCategoriaIndiceColumn(db);
    await _normalizarIndicesCategorias(db);
  }

  Future<void> ensureCategoriaIndiceColumn([DatabaseExecutor? executor]) async {
    final db = executor ?? await database;
    final columnas = await db.rawQuery("PRAGMA table_info('LC_categorias')");
    final tieneIndice = columnas.any(
      (columna) => columna['name']?.toString() == 'indice',
    );

    if (!tieneIndice) {
      await db.execute(
        'ALTER TABLE LC_categorias ADD COLUMN indice INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  Future<void> _normalizarIndicesCategorias(DatabaseExecutor db) async {
    await ensureCategoriaIndiceColumn(db);
    final categorias = await db.query('LC_categorias');
    if (categorias.isEmpty) {
      return;
    }

    final categoriasNormales =
        categorias
            .where(
              (categoria) =>
                  (categoria['nombre']?.toString().trim().toLowerCase() ??
                      '') !=
                  Categoria.nombreBase.toLowerCase(),
            )
            .toList()
          ..sort((a, b) {
            final indiceA = (a['indice'] as num?)?.toInt() ?? 0;
            final indiceB = (b['indice'] as num?)?.toInt() ?? 0;
            if (indiceA != indiceB) {
              return indiceA.compareTo(indiceB);
            }

            final nombreA = a['nombre']?.toString() ?? '';
            final nombreB = b['nombre']?.toString() ?? '';
            return nombreA.toLowerCase().compareTo(nombreB.toLowerCase());
          });

    for (var i = 0; i < categoriasNormales.length; i++) {
      await db.update(
        'LC_categorias',
        {'indice': i + 1},
        where: 'id_categoria = ?',
        whereArgs: [categoriasNormales[i]['id_categoria']],
      );
    }

    final categoriaBase = categorias.cast<Map<String, Object?>>().firstWhere(
      (categoria) =>
          (categoria['nombre']?.toString().trim().toLowerCase() ?? '') ==
          Categoria.nombreBase.toLowerCase(),
      orElse: () => <String, Object?>{},
    );

    if (categoriaBase.isNotEmpty) {
      await db.update(
        'LC_categorias',
        {'indice': categoriasNormales.length + 1},
        where: 'id_categoria = ?',
        whereArgs: [categoriaBase['id_categoria']],
      );
    }
  }
}
