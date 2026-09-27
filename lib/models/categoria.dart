class Categoria {
  final int? idCategoria;
  final String nombre;
  final String color;
  final int indice;

  const Categoria({
    this.idCategoria,
    required this.nombre,
    required this.color,
    required this.indice,
  });

  static const String nombreBase = 'Ninguna';
  static const String colorBase = '#9E9E9E';

  bool get esBase => nombre.trim().toLowerCase() == nombreBase.toLowerCase();

  Map<String, dynamic> toMap() {
    return {
      'id_categoria': idCategoria,
      'nombre': nombre,
      'color': color,
      'indice': indice,
    };
  }

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      idCategoria: map['id_categoria'] as int?,
      nombre: map['nombre']?.toString() ?? '',
      color: map['color']?.toString() ?? colorBase,
      indice: (map['indice'] as num?)?.toInt() ?? 0,
    );
  }
}
