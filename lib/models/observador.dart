class Observador {
  final int? idObservador;
  final String nombre;
  final String pin;

  Observador({this.idObservador, required this.nombre, required this.pin});

  Map<String, dynamic> toMap() {
    return {'id_observador': idObservador, 'nombre': nombre, 'pin': pin};
  }

  factory Observador.fromMap(Map<String, dynamic> map) {
    return Observador(
      idObservador: map['id_observador'],
      nombre: map['nombre'] ?? '',
      pin: map['pin'] ?? '',
    );
  }
}
