class Reporte {
  final int? idReporte;
  final String fecha;
  final int idRepartidor;
  final int idObservador;
  final int? idUltimoEditor;
  final String? fechaUltimaEdicion;

  Reporte({
    this.idReporte,
    required this.fecha,
    required this.idRepartidor,
    required this.idObservador,
    this.idUltimoEditor,
    this.fechaUltimaEdicion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_reporte': idReporte,
      'fecha': fecha,
      'id_repartidor': idRepartidor,
      'id_observador': idObservador,
      'id_ultimo_editor': idUltimoEditor,
      'fecha_ultima_edicion': fechaUltimaEdicion,
    };
  }

  factory Reporte.fromMap(Map<String, dynamic> map) {
    return Reporte(
      idReporte: map['id_reporte'],
      fecha: map['fecha'] ?? '',
      idRepartidor: map['id_repartidor'],
      idObservador: map['id_observador'],
      idUltimoEditor: map['id_ultimo_editor'],
      fechaUltimaEdicion: map['fecha_ultima_edicion'],
    );
  }
}
