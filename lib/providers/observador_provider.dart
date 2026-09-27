import 'package:flutter/material.dart';
import '../models/observador.dart';
import '../services/reporte_service.dart';

class ObservadorProvider extends ChangeNotifier {
  final ReporteService _reporteService = ReporteService();

  List<Observador> _observadores = [];
  bool _isLoading = false;

  List<Observador> get observadores => _observadores;
  bool get isLoading => _isLoading;

  Future<void> cargarObservadores() async {
    _isLoading = true;
    notifyListeners();

    _observadores = await _reporteService.listarObservadores();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> agregarObservador(Observador observador) async {
    await _reporteService.guardarObservador(observador);
    await cargarObservadores();
  }

  Future<void> actualizarObservador(Observador observador) async {
    await _reporteService.editarObservador(observador);
    await cargarObservadores();
  }

  Future<bool> eliminarObservador(int idObservador) async {
    final eliminado = await _reporteService.eliminarObservador(idObservador);
    if (eliminado) await cargarObservadores();
    return eliminado;
  }
}
