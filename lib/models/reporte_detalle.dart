class ReporteDetalle {
  final int? idDetalle;
  final int idReporte;
  final int idProducto;
  final double cantidadTraia;
  final double cantidadCargo;

  ReporteDetalle({
    this.idDetalle,
    required this.idReporte,
    required this.idProducto,
    required this.cantidadTraia,
    required this.cantidadCargo,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_detalle': idDetalle,
      'id_reporte': idReporte,
      'id_producto': idProducto,
      'cantidad_traia': cantidadTraia,
      'cantidad_cargo': cantidadCargo,
    };
  }

  factory ReporteDetalle.fromMap(Map<String, dynamic> map) {
    return ReporteDetalle(
      idDetalle: map['id_detalle'],
      idReporte: map['id_reporte'],
      idProducto: map['id_producto'],
      cantidadTraia: (map['cantidad_traia'] as num).toDouble(),
      cantidadCargo: (map['cantidad_cargo'] as num).toDouble(),
    );
  }
}
