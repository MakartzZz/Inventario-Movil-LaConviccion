import '../../models/observador.dart';

class SessionManager {
  static Observador? observadorActual;

  static bool get haySesion => observadorActual != null;

  static int? get idObservadorActual => observadorActual?.idObservador;

  static String? get nombreObservadorActual => observadorActual?.nombre;

  static void iniciarSesion(Observador observador) {
    observadorActual = observador;
  }

  static void cerrarSesion() {
    observadorActual = null;
  }
}
