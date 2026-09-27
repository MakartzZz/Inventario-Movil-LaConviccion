import 'package:flutter/material.dart';

import '../models/categoria.dart';
import '../models/producto.dart';
import '../services/categoria_service.dart';
import '../services/producto_service.dart';

class ProductoProvider extends ChangeNotifier {
  final ProductoService _productoService = ProductoService();
  final CategoriaService _categoriaService = CategoriaService();

  List<Producto> _productos = [];
  List<Categoria> _categorias = [];
  bool _isLoading = false;

  List<Producto> get productos => _productos;
  List<Categoria> get categorias => _categorias;
  bool get isLoading => _isLoading;

  Future<void> cargarProductos() async {
    _isLoading = true;
    notifyListeners();

    _categorias = await _categoriaService.listarCategorias();
    _productos = await _productoService.listarProductos();
    _ordenarProductosSegunCategorias();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> agregarProducto(Producto producto) async {
    await _productoService.guardarProducto(producto);
    await cargarProductos();
  }

  Future<void> actualizarProducto(Producto producto) async {
    await _productoService.editarProducto(producto);
    await cargarProductos();
  }

  Future<bool> borrarProducto(int idProducto) async {
    final eliminado = await _productoService.eliminarProducto(idProducto);
    if (eliminado) {
      await cargarProductos();
    }
    return eliminado;
  }

  Future<bool> nombreCategoriaDisponible(
    String nombre, {
    int? ignorarIdCategoria,
  }) async {
    return !(await _categoriaService.existeNombreCategoria(
      nombre,
      ignorarIdCategoria: ignorarIdCategoria,
    ));
  }

  Future<void> agregarCategoria(Categoria categoria) async {
    try {
      await _categoriaService.guardarCategoria(categoria);
    } catch (error, stackTrace) {
      debugPrint('ProductoProvider.agregarCategoria fallo: $error');
      debugPrintStack(
        label: 'Stack ProductoProvider.agregarCategoria',
        stackTrace: stackTrace,
      );
      rethrow;
    }
    await cargarProductos();
  }

  Future<void> actualizarCategoria(Categoria categoria) async {
    await _categoriaService.editarCategoria(categoria);
    await cargarProductos();
  }

  Future<void> borrarCategoria(int idCategoria) async {
    await _categoriaService.eliminarCategoria(idCategoria);
    await cargarProductos();
  }

  Future<void> reordenarCategoria({
    required int idCategoria,
    required List<int> idsProductosOrdenados,
  }) async {
    final productosPrevios = List<Producto>.from(_productos);
    final productosCategoria = _productos
        .where((producto) => producto.idCategoria == idCategoria)
        .toList();

    final productosPorId = {
      for (final producto in productosCategoria) producto.idProducto!: producto,
    };

    final productosReordenados = <Producto>[];
    for (var i = 0; i < idsProductosOrdenados.length; i++) {
      final producto = productosPorId[idsProductosOrdenados[i]];
      if (producto == null) {
        _productos = productosPrevios;
        notifyListeners();
        throw StateError('No se encontro un producto para reordenar.');
      }

      productosReordenados.add(
        Producto(
          idProducto: producto.idProducto,
          nombre: producto.nombre,
          precio: producto.precio,
          esContable: producto.esContable,
          indice: i + 1,
          idCategoria: producto.idCategoria,
        ),
      );
    }

    final productosOtrasCategorias = _productos
        .where((producto) => producto.idCategoria != idCategoria)
        .toList();

    _productos = [...productosOtrasCategorias, ...productosReordenados]
      ..sort((a, b) {
        if (a.idCategoria != b.idCategoria) {
          return a.idCategoria.compareTo(b.idCategoria);
        }
        if (a.indice != b.indice) {
          return a.indice.compareTo(b.indice);
        }
        return a.nombre.compareTo(b.nombre);
      });

    notifyListeners();

    try {
      await _productoService.reordenarCategoria(
        idCategoria: idCategoria,
        idsProductosOrdenados: idsProductosOrdenados,
      );
    } catch (_) {
      _productos = productosPrevios;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> reordenarCategorias({
    required List<int> idsCategoriasOrdenadas,
  }) async {
    final categoriasPrevias = List<Categoria>.from(_categorias);
    final productosPrevios = List<Producto>.from(_productos);

    final categoriasPorId = {
      for (final categoria in _categorias) categoria.idCategoria!: categoria,
    };

    final categoriasNormales = <Categoria>[];
    for (var i = 0; i < idsCategoriasOrdenadas.length; i++) {
      final categoria = categoriasPorId[idsCategoriasOrdenadas[i]];
      if (categoria == null || categoria.esBase) {
        _categorias = categoriasPrevias;
        _productos = productosPrevios;
        notifyListeners();
        throw StateError('No se encontro una categoria para reordenar.');
      }

      categoriasNormales.add(
        Categoria(
          idCategoria: categoria.idCategoria,
          nombre: categoria.nombre,
          color: categoria.color,
          indice: i + 1,
        ),
      );
    }

    final categoriaBase = _categorias.where((categoria) => categoria.esBase);
    _categorias = [...categoriasNormales, ...categoriaBase]
      ..sort((a, b) => a.indice.compareTo(b.indice));
    _ordenarProductosSegunCategorias();
    notifyListeners();

    try {
      await _categoriaService.reordenarCategorias(idsCategoriasOrdenadas);
    } catch (_) {
      _categorias = categoriasPrevias;
      _productos = productosPrevios;
      notifyListeners();
      rethrow;
    }
  }

  void _ordenarProductosSegunCategorias() {
    final ordenCategorias = {
      for (final categoria in _categorias)
        categoria.idCategoria!: categoria.indice,
    };

    _productos.sort((a, b) {
      final ordenA = ordenCategorias[a.idCategoria] ?? 999999;
      final ordenB = ordenCategorias[b.idCategoria] ?? 999999;
      if (ordenA != ordenB) {
        return ordenA.compareTo(ordenB);
      }
      if (a.indice != b.indice) {
        return a.indice.compareTo(b.indice);
      }
      return a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
    });
  }
}
