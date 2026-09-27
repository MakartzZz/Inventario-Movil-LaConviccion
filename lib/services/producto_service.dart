import '../database/database_helper.dart';
import '../models/producto.dart';

class ProductoService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> guardarProducto(Producto producto) async {
    final db = await _databaseHelper.database;
    final idCategoriaBase = await _databaseHelper.ensureCategoriaBase();
    final idCategoria = producto.idCategoria == 0
        ? idCategoriaBase
        : producto.idCategoria;

    final indiceNuevo = await _siguienteIndiceParaCategoria(idCategoria);

    final data = producto.toMap();
    data.remove('id_producto');
    data['id_categoria'] = idCategoria;
    data['indice'] = indiceNuevo;

    return db.insert('LC_productos', data);
  }

  Future<List<Producto>> listarProductos() async {
    final db = await _databaseHelper.database;
    await _databaseHelper.ensureCategoriaBase();

    final result = await db.rawQuery('''
      SELECT p.*
      FROM LC_productos p
      INNER JOIN LC_categorias c ON c.id_categoria = p.id_categoria
      ORDER BY c.indice ASC, p.indice ASC, p.nombre COLLATE NOCASE ASC
      ''');

    return result.map(Producto.fromMap).toList();
  }

  Future<int> editarProducto(Producto producto) async {
    final db = await _databaseHelper.database;
    final idCategoriaBase = await _databaseHelper.ensureCategoriaBase();
    final idCategoriaDestino = producto.idCategoria == 0
        ? idCategoriaBase
        : producto.idCategoria;

    final existente = await db.query(
      'LC_productos',
      where: 'id_producto = ?',
      whereArgs: [producto.idProducto],
      limit: 1,
    );

    if (existente.isEmpty) return 0;

    final productoActual = Producto.fromMap(existente.first);

    return db.transaction((txn) async {
      var indiceFinal = productoActual.indice;

      if (productoActual.idCategoria != idCategoriaDestino) {
        indiceFinal = await _siguienteIndiceParaCategoria(
          idCategoriaDestino,
          executor: txn,
        );
      }

      final actualizado = await txn.update(
        'LC_productos',
        {
          'nombre': producto.nombre,
          'precio': producto.precio,
          'es_contable': producto.esContable ? 1 : 0,
          'id_categoria': idCategoriaDestino,
          'indice': indiceFinal,
        },
        where: 'id_producto = ?',
        whereArgs: [producto.idProducto],
      );

      if (productoActual.idCategoria != idCategoriaDestino) {
        await _normalizarIndicesCategoria(
          productoActual.idCategoria,
          executor: txn,
        );
      }

      return actualizado;
    });
  }

  Future<bool> eliminarProducto(int idProducto) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'LC_reporte_detalle',
      where: 'id_producto = ?',
      whereArgs: [idProducto],
      limit: 1,
    );

    if (result.isNotEmpty) return false;

    final producto = await db.query(
      'LC_productos',
      where: 'id_producto = ?',
      whereArgs: [idProducto],
      limit: 1,
    );

    if (producto.isEmpty) return false;

    final idCategoria = (producto.first['id_categoria'] as num).toInt();

    await db.transaction((txn) async {
      await txn.delete(
        'LC_productos',
        where: 'id_producto = ?',
        whereArgs: [idProducto],
      );

      await _normalizarIndicesCategoria(idCategoria, executor: txn);
    });

    return true;
  }

  Future<void> reordenarCategoria({
    required int idCategoria,
    required List<int> idsProductosOrdenados,
  }) async {
    final db = await _databaseHelper.database;

    await db.transaction((txn) async {
      for (var i = 0; i < idsProductosOrdenados.length; i++) {
        await txn.update(
          'LC_productos',
          {'indice': i + 1},
          where: 'id_producto = ? AND id_categoria = ?',
          whereArgs: [idsProductosOrdenados[i], idCategoria],
        );
      }
    });
  }

  Future<int> _siguienteIndiceParaCategoria(
    int idCategoria, {
    dynamic executor,
  }) async {
    final db = executor ?? await _databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT MAX(indice) AS max_indice FROM LC_productos WHERE id_categoria = ?',
      [idCategoria],
    );

    final valor = result.first['max_indice'] as num?;
    return (valor?.toInt() ?? 0) + 1;
  }

  Future<void> _normalizarIndicesCategoria(
    int idCategoria, {
    dynamic executor,
  }) async {
    final db = executor ?? await _databaseHelper.database;
    final productos = await db.query(
      'LC_productos',
      where: 'id_categoria = ?',
      whereArgs: [idCategoria],
      orderBy: 'indice ASC, nombre ASC',
    );

    for (var i = 0; i < productos.length; i++) {
      await db.update(
        'LC_productos',
        {'indice': i + 1},
        where: 'id_producto = ?',
        whereArgs: [productos[i]['id_producto']],
      );
    }
  }
}
