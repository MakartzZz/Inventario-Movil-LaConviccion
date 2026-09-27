import '../database/database_helper.dart';
import '../models/categoria.dart';

class CategoriaService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  String normalizarNombre(String nombre) {
    return nombre.trim().toLowerCase();
  }

  Future<List<Categoria>> listarCategorias() async {
    final db = await _databaseHelper.database;
    await _databaseHelper.ensureCategoriaIndiceColumn(db);
    await _databaseHelper.ensureCategoriaBase();
    await _databaseHelper.normalizarIndicesCategorias();

    final result = await db.query(
      'LC_categorias',
      orderBy: 'indice ASC, nombre ASC',
    );

    return result.map(Categoria.fromMap).toList();
  }

  Future<bool> existeNombreCategoria(
    String nombre, {
    int? ignorarIdCategoria,
  }) async {
    final db = await _databaseHelper.database;
    final categorias = await db.query('LC_categorias');
    final nombreNormalizado = normalizarNombre(nombre);

    for (final categoria in categorias) {
      final id = (categoria['id_categoria'] as num).toInt();
      if (ignorarIdCategoria != null && id == ignorarIdCategoria) {
        continue;
      }

      final nombreExistente = normalizarNombre(
        categoria['nombre']?.toString() ?? '',
      );
      if (nombreExistente == nombreNormalizado) {
        return true;
      }
    }

    return false;
  }

  Future<int> guardarCategoria(Categoria categoria) async {
    final db = await _databaseHelper.database;
    await _databaseHelper.ensureCategoriaIndiceColumn(db);
    return db.transaction((txn) async {
      final id = await txn.insert('LC_categorias', {
        'nombre': categoria.nombre,
        'color': categoria.color,
        'indice': await _siguienteIndiceCategoria(txn),
      });
      await _normalizarIndicesCategorias(txn);
      return id;
    });
  }

  Future<int> editarCategoria(Categoria categoria) async {
    final db = await _databaseHelper.database;
    await _databaseHelper.ensureCategoriaIndiceColumn(db);
    return db.transaction((txn) async {
      final actualizadas = await txn.update(
        'LC_categorias',
        {'nombre': categoria.nombre, 'color': categoria.color},
        where: 'id_categoria = ?',
        whereArgs: [categoria.idCategoria],
      );
      await _normalizarIndicesCategorias(txn);
      return actualizadas;
    });
  }

  Future<void> eliminarCategoria(int idCategoria) async {
    final db = await _databaseHelper.database;
    await _databaseHelper.ensureCategoriaIndiceColumn(db);
    final idCategoriaBase = await _databaseHelper.ensureCategoriaBase();

    await db.transaction((txn) async {
      await txn.update(
        'LC_productos',
        {'id_categoria': idCategoriaBase},
        where: 'id_categoria = ?',
        whereArgs: [idCategoria],
      );

      await txn.delete(
        'LC_categorias',
        where: 'id_categoria = ?',
        whereArgs: [idCategoria],
      );

      await _normalizarIndicesCategorias(txn);
    });
  }

  Future<void> reordenarCategorias(List<int> idsCategoriasOrdenadas) async {
    final db = await _databaseHelper.database;
    await _databaseHelper.ensureCategoriaIndiceColumn(db);

    await db.transaction((txn) async {
      for (var i = 0; i < idsCategoriasOrdenadas.length; i++) {
        await txn.update(
          'LC_categorias',
          {'indice': i + 1},
          where: 'id_categoria = ?',
          whereArgs: [idsCategoriasOrdenadas[i]],
        );
      }

      await _normalizarIndicesCategorias(txn);
    });
  }

  Future<void> _normalizarIndicesCategorias(dynamic executor) async {
    final db = executor ?? await _databaseHelper.database;
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

  Future<int> _siguienteIndiceCategoria(dynamic executor) async {
    final db = executor ?? await _databaseHelper.database;
    final categorias = await db.query('LC_categorias');
    final categoriasNormales = categorias.where(
      (categoria) =>
          (categoria['nombre']?.toString().trim().toLowerCase() ?? '') !=
          Categoria.nombreBase.toLowerCase(),
    );

    var maxIndice = 0;
    for (final categoria in categoriasNormales) {
      final indice = (categoria['indice'] as num?)?.toInt() ?? 0;
      if (indice > maxIndice) {
        maxIndice = indice;
      }
    }

    return maxIndice + 1;
  }
}
