class Producto {
  final int? idProducto;
  final String nombre;
  final double precio;
  final bool esContable;
  final int indice;
  final int idCategoria;

  Producto({
    this.idProducto,
    required this.nombre,
    required this.precio,
    required this.esContable,
    required this.indice,
    required this.idCategoria,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_producto': idProducto,
      'nombre': nombre,
      'precio': precio,
      'es_contable': esContable ? 1 : 0,
      'indice': indice,
      'id_categoria': idCategoria,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      idProducto: map['id_producto'],
      nombre: map['nombre'] ?? '',
      precio: (map['precio'] as num).toDouble(),
      esContable: map['es_contable'] == 1,
      indice: (map['indice'] as num?)?.toInt() ?? 0,
      idCategoria: (map['id_categoria'] as num?)?.toInt() ?? 0,
    );
  }
}
