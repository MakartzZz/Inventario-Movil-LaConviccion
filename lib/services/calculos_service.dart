import '../models/producto.dart';
import '../models/reporte_detalle.dart';

class CalculosService {
  // =========================
  // 📦 TOTAL POR PRODUCTO (UNIDADES)
  // =========================
  double totalPorProducto({
    required double cantidadTraia,
    required double cantidadCargo,
  }) {
    return cantidadTraia + cantidadCargo;
  }

  // =========================
  // 📦 SUMA DE TRAÍA (UNIDADES - SOLO CONTABLES)
  // =========================
  double sumaTraiaUnidades({
    required List<Producto> productos,
    required List<ReporteDetalle> detalles,
  }) {
    double total = 0;

    for (final detalle in detalles) {
      final producto = productos.firstWhere(
        (p) => p.idProducto == detalle.idProducto,
      );

      if (producto.esContable) {
        total += detalle.cantidadTraia;
      }
    }

    return total;
  }

  // =========================
  // 📦 SUMA DE CARGÓ (UNIDADES - SOLO CONTABLES)
  // =========================
  double sumaCargoUnidades({
    required List<Producto> productos,
    required List<ReporteDetalle> detalles,
  }) {
    double total = 0;

    for (final detalle in detalles) {
      final producto = productos.firstWhere(
        (p) => p.idProducto == detalle.idProducto,
      );

      if (producto.esContable) {
        total += detalle.cantidadCargo;
      }
    }

    return total;
  }

  // =========================
  // 📦 TOTAL GENERAL (UNIDADES)
  // =========================
  double sumaTotalUnidades({
    required List<Producto> productos,
    required List<ReporteDetalle> detalles,
  }) {
    return sumaTraiaUnidades(productos: productos, detalles: detalles) +
        sumaCargoUnidades(productos: productos, detalles: detalles);
  }

  // =========================
  // 💰 VALOR TOTAL EN BUS (MONETARIO)
  // =========================
  double valorTotalInventario({
    required List<Producto> productos,
    required List<ReporteDetalle> detalles,
  }) {
    double total = 0;

    for (final detalle in detalles) {
      final producto = productos.firstWhere(
        (p) => p.idProducto == detalle.idProducto,
      );

      final double cantidadTotal =
          detalle.cantidadTraia + detalle.cantidadCargo;

      total += cantidadTotal * producto.precio;
    }

    return total;
  }
}
