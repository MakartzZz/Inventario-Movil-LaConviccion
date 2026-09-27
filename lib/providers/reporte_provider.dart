import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../models/repartidor.dart';
import '../models/observador.dart';
import '../models/reporte.dart';
import '../models/reporte_detalle.dart';
import '../services/reporte_service.dart';
import '../services/producto_service.dart';

class ReporteProvider extends ChangeNotifier {
  final ReporteService _reporteService = ReporteService();
  final ProductoService _productoService = ProductoService();

  List<Producto> _productos = [];
  List<Repartidor> _repartidores = [];
  List<Observador> _observadores = [];
  List<ReporteDetalle> _detalles = [];

  bool _isLoading = false;
  bool _guardando = false;
  int? _idReporteActual;

  List<Producto> get productos => _productos;
  List<Repartidor> get repartidores => _repartidores;
  List<Observador> get observadores => _observadores;
  List<ReporteDetalle> get detalles => _detalles;

  bool get isLoading => _isLoading;
  bool get guardando => _guardando;
  int? get idReporteActual => _idReporteActual;

  List<Reporte> _reportes = [];
  String? _fechaFiltro;

  List<Reporte> get reportes => _reportes;
  String? get fechaFiltro => _fechaFiltro;

  Future<void> cargarDatosBase() async {
    _isLoading = true;
    notifyListeners();

    _productos = await _productoService.listarProductos();
    _repartidores = await _reporteService.listarRepartidores();
    _observadores = await _reporteService.listarObservadores();

    _isLoading = false;
    notifyListeners();
  }

  void limpiarDetalles() {
    _detalles = [];
    _idReporteActual = null;
    notifyListeners();
  }

  void construirDetallesDesdeFormulario({
    required List<Producto> productos,
    required Map<int, double> cantidadesTraia,
    required Map<int, double> cantidadesCargo,
  }) {
    final List<ReporteDetalle> nuevosDetalles = [];

    for (final producto in productos) {
      final int idProducto = producto.idProducto!;
      final double cantidadTraia = cantidadesTraia[idProducto] ?? 0;
      final double cantidadCargo = cantidadesCargo[idProducto] ?? 0;

      nuevosDetalles.add(
        ReporteDetalle(
          idReporte: 0,
          idProducto: idProducto,
          cantidadTraia: cantidadTraia,
          cantidadCargo: cantidadCargo,
        ),
      );
    }

    _detalles = nuevosDetalles;
    notifyListeners();
  }

  Future<bool> guardarReporteCompleto({
    required String fecha,
    required int idRepartidor,
    required int idObservador,
    int? idUltimoEditor,
    String? fechaUltimaEdicion,
  }) async {
    try {
      _guardando = true;
      notifyListeners();

      final reporte = Reporte(
        fecha: fecha,
        idRepartidor: idRepartidor,
        idObservador: idObservador,
        idUltimoEditor: idUltimoEditor,
        fechaUltimaEdicion: fechaUltimaEdicion,
      );

      final int idReporte = await _reporteService.guardarReporteCompleto(
        reporte: reporte,
        detalles: _detalles,
      );

      _idReporteActual = idReporte;
      _guardando = false;
      notifyListeners();

      return true;
    } catch (e) {
      _guardando = false;
      notifyListeners();
      return false;
    }
  }

  Future<List<Reporte>> obtenerReportesPorFecha(String fecha) async {
    return await _reporteService.obtenerReportesPorFecha(fecha);
  }

  Future<List<ReporteDetalle>> obtenerDetallesPorReporte(int idReporte) async {
    return await _reporteService.obtenerDetallesPorReporte(idReporte);
  }

  Future<void> cargarReportes() async {
    _isLoading = true;
    notifyListeners();

    _reportes = await _reporteService.listarReportes();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> filtrarPorFecha(String fecha) async {
    _isLoading = true;
    _fechaFiltro = fecha;
    notifyListeners();

    _reportes = await _reporteService.listarReportesPorFecha(fecha);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> limpiarFiltro() async {
    _fechaFiltro = null;
    await cargarReportes();
  }

  Future<bool> editarReporte({
    required int idReporte,
    required int idUltimoEditor,
    required String fechaUltimaEdicion,
  }) async {
    try {
      _guardando = true;
      notifyListeners();

      await _reporteService.editarReporteCompleto(
        idReporte: idReporte,
        idUltimoEditor: idUltimoEditor,
        fechaUltimaEdicion: fechaUltimaEdicion,
        detalles: _detalles,
      );

      _guardando = false;
      notifyListeners();

      await cargarReportes();
      return true;
    } catch (e) {
      _guardando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarReporte(int idReporte) async {
    try {
      await _reporteService.eliminarReporte(idReporte);
      await cargarReportes();
      return true;
    } catch (e) {
      return false;
    }
  }
}
