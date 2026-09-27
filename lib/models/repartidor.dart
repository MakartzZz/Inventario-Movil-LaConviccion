class Repartidor {
  final int? idRepartidor;
  final String nombre;

  Repartidor({this.idRepartidor, required this.nombre});

  Map<String, dynamic> toMap() {
    return {'id_repartidor': idRepartidor, 'nombre': nombre};
  }

  factory Repartidor.fromMap(Map<String, dynamic> map) {
    return Repartidor(
      idRepartidor: map['id_repartidor'],
      nombre: map['nombre'] ?? '',
    );
  }
}
