import 'package:flutter/material.dart';
import '../models/repartidor.dart';
import '../services/reporte_service.dart';

class RepartidorProvider extends ChangeNotifier {
  final ReporteService _reporteService = ReporteService();

  List<Repartidor> _repartidores = [];
  bool _isLoading = false;

  List<Repartidor> get repartidores => _repartidores;
  bool get isLoading => _isLoading;

  Future<void> cargarRepartidores() async {
    _isLoading = true;
    notifyListeners();

    _repartidores = await _reporteService.listarRepartidores();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> agregarRepartidor(Repartidor repartidor) async {
    await _reporteService.guardarRepartidor(repartidor);
    await cargarRepartidores();
  }

  Future<void> actualizarRepartidor(Repartidor repartidor) async {
    await _reporteService.editarRepartidor(repartidor);
    await cargarRepartidores();
  }
}
