import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/utils/helpers.dart';
import '../../models/categoria.dart';
import '../../models/observador.dart';
import '../../models/producto.dart';
import '../../models/repartidor.dart';
import '../../models/reporte.dart';
import '../../models/reporte_detalle.dart';
import '../../services/calculos_service.dart';
import '../../services/categoria_service.dart';
import '../../services/export_service.dart';
import '../../services/producto_service.dart';
import '../../services/reporte_service.dart';
import '../widgets/reporte_detalle_card.dart';

class ReporteResumenScreen extends StatefulWidget {
  final Reporte reporte;

  const ReporteResumenScreen({super.key, required this.reporte});

  @override
  State<ReporteResumenScreen> createState() => _ReporteResumenScreenState();
}

class _ReporteResumenScreenState extends State<ReporteResumenScreen> {
  final ExportService _exportService = ExportService();
  final ReporteService _reporteService = ReporteService();
  final ProductoService _productoService = ProductoService();
  final CategoriaService _categoriaService = CategoriaService();
  final CalculosService _calculosService = CalculosService();

  bool _isLoading = true;

  List<ReporteDetalle> _detalles = [];
  List<Producto> _productos = [];
  List<Repartidor> _repartidores = [];
  List<Observador> _observadores = [];
  Map<int, Categoria> _categoriasPorId = {};

  @override
  void initState() {
    super.initState();
    _cargarResumen();
  }

  Future<void> _compartirComoPdf() async {
    try {
      final repartidorNombre = _repartidor?.nombre ?? 'No encontrado';
      final observadorNombre = _observador?.nombre ?? 'No encontrado';
      final ultimoEditorNombre = _ultimoEditor?.nombre;

      final productosPdf = _detalles.map((detalle) {
        final producto = _buscarProducto(detalle.idProducto);
        final totalProducto = _calculosService.totalPorProducto(
          cantidadTraia: detalle.cantidadTraia,
          cantidadCargo: detalle.cantidadCargo,
        );

        return <String, dynamic>{
          'nombre': producto?.nombre ?? 'Producto no encontrado',
          'traia': Helpers.formatearCantidad(detalle.cantidadTraia),
          'cargo': Helpers.formatearCantidad(detalle.cantidadCargo),
          'total': Helpers.formatearCantidad(totalProducto),
        };
      }).toList();

      final totalTraia = _calculosService.sumaTraiaUnidades(
        productos: _productos,
        detalles: _detalles,
      );
      final totalCargo = _calculosService.sumaCargoUnidades(
        productos: _productos,
        detalles: _detalles,
      );
      final totalGeneral = _calculosService.sumaTotalUnidades(
        productos: _productos,
        detalles: _detalles,
      );
      final valorTotal = _calculosService.valorTotalInventario(
        productos: _productos,
        detalles: _detalles,
      );

      final file = await _exportService.generarPdfReporte(
        fecha: widget.reporte.fecha,
        repartidor: repartidorNombre,
        observador: observadorNombre,
        fueEditado: widget.reporte.idUltimoEditor != null,
        ultimoEditor: ultimoEditorNombre,
        fechaEdicion: widget.reporte.fechaUltimaEdicion,
        productos: productosPdf,
        totalTraia: Helpers.formatearCantidad(totalTraia),
        totalCargo: Helpers.formatearCantidad(totalCargo),
        totalGeneral: Helpers.formatearCantidad(totalGeneral),
        valorTotal: Helpers.formatearMonedaPdf(valorTotal),
      );

      await _exportService.compartirPdf(file);
    } catch (e, s) {
      debugPrint('ERROR AL COMPARTIR PDF: $e');
      debugPrint('$s');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al generar PDF: $e')));
    }
  }

  Future<void> _cargarResumen() async {
    final detalles = await _reporteService.obtenerDetallesPorReporte(
      widget.reporte.idReporte!,
    );
    final productos = await _productoService.listarProductos();
    final categorias = await _categoriaService.listarCategorias();
    final repartidores = await _reporteService.listarRepartidores();
    final observadores = await _reporteService.listarObservadores();

    if (!mounted) return;

    setState(() {
      _detalles = detalles;
      _productos = productos;
      _categoriasPorId = {
        for (final categoria in categorias)
          if (categoria.idCategoria != null) categoria.idCategoria!: categoria,
      };
      _repartidores = repartidores;
      _observadores = observadores;
      _isLoading = false;
    });
  }

  Color _colorDesdeHex(String hex) {
    final limpio = hex.replaceFirst('#', '');
    return Color(int.parse('FF$limpio', radix: 16));
  }

  Color _colorCategoriaProducto(Producto producto) {
    final categoria = _categoriasPorId[producto.idCategoria];
    if (categoria == null) {
      return const Color(0xFF9E9E9E);
    }
    return _colorDesdeHex(categoria.color);
  }

  Repartidor? get _repartidor {
    try {
      return _repartidores.firstWhere(
        (repartidor) => repartidor.idRepartidor == widget.reporte.idRepartidor,
      );
    } catch (_) {
      return null;
    }
  }

  Observador? get _observador {
    try {
      return _observadores.firstWhere(
        (observador) => observador.idObservador == widget.reporte.idObservador,
      );
    } catch (_) {
      return null;
    }
  }

  Observador? get _ultimoEditor {
    if (widget.reporte.idUltimoEditor == null) return null;

    try {
      return _observadores.firstWhere(
        (observador) =>
            observador.idObservador == widget.reporte.idUltimoEditor,
      );
    } catch (_) {
      return null;
    }
  }

  Producto? _buscarProducto(int idProducto) {
    try {
      return _productos.firstWhere(
        (producto) => producto.idProducto == idProducto,
      );
    } catch (_) {
      return null;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF8C4F00)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B5C48),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF29170C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncabezado() {
    final fueEditado = widget.reporte.idUltimoEditor != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6A817).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: Color(0xFF8C4F00),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reporte',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B5C48),
                      ),
                    ),
                    Text(
                      widget.reporte.fecha,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF29170C),
                      ),
                    ),
                  ],
                ),
              ),
              if (fueEditado)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6E4C8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit_rounded,
                        size: 12,
                        color: Color(0xFF8C4F00),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Editado',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8C4F00),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFE6D9C7)),
          const SizedBox(height: 14),
          _buildInfoRow(
            Icons.local_shipping_rounded,
            'Repartidor',
            _repartidor?.nombre ?? 'No encontrado',
          ),
          _buildInfoRow(
            Icons.visibility_rounded,
            'Observador',
            _observador?.nombre ?? 'No encontrado',
          ),
          if (fueEditado) ...[
            const SizedBox(height: 4),
            Container(height: 1, color: const Color(0xFFE6D9C7)),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.manage_accounts_rounded,
              'Ultimo editor',
              _ultimoEditor?.nombre ?? 'No encontrado',
            ),
            _buildInfoRow(
              Icons.calendar_today_rounded,
              'Fecha edición',
              widget.reporte.fechaUltimaEdicion ?? 'No disponible',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListaProductos() {
    if (_detalles.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.68),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: const Color(0xFFE6A817).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 10),
            Text(
              'Este reporte no tiene productos',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B5C48),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _detalles.map((detalle) {
        final producto = _buscarProducto(detalle.idProducto);
        final totalProducto = _calculosService.totalPorProducto(
          cantidadTraia: detalle.cantidadTraia,
          cantidadCargo: detalle.cantidadCargo,
        );

        return ReporteDetalleCard(
          nombreProducto: producto?.nombre ?? 'Producto no encontrado',
          cantidadTraia: detalle.cantidadTraia,
          cantidadCargo: detalle.cantidadCargo,
          totalProducto: totalProducto,
          colorCategoria: producto != null
              ? _colorCategoriaProducto(producto)
              : const Color(0xFF9E9E9E),
        );
      }).toList(),
    );
  }

  Widget _buildResumenRow(
    String label,
    String value, {
    bool destacado = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: destacado ? 14 : 13,
              fontWeight: destacado ? FontWeight.w700 : FontWeight.w600,
              color: const Color(0xFF6B5C48),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: destacado ? 15 : 13,
            fontWeight: destacado ? FontWeight.w800 : FontWeight.w700,
            color: const Color(0xFF29170C),
          ),
        ),
      ],
    );
  }

  Widget _buildResumenNumerico() {
    final totalTraia = _calculosService.sumaTraiaUnidades(
      productos: _productos,
      detalles: _detalles,
    );
    final totalCargo = _calculosService.sumaCargoUnidades(
      productos: _productos,
      detalles: _detalles,
    );
    final totalGeneral = _calculosService.sumaTotalUnidades(
      productos: _productos,
      detalles: _detalles,
    );
    final valorTotal = _calculosService.valorTotalInventario(
      productos: _productos,
      detalles: _detalles,
    );

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF29170C),
            ),
          ),
          const SizedBox(height: 14),
          _buildResumenRow(
            'Total traia',
            '${Helpers.formatearCantidad(totalTraia)} monos',
          ),
          const SizedBox(height: 8),
          _buildResumenRow(
            'Total cargo',
            '${Helpers.formatearCantidad(totalCargo)} monos',
          ),
          const SizedBox(height: 8),
          _buildResumenRow(
            'Total general',
            '${Helpers.formatearCantidad(totalGeneral)} monos',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE6D9C7)),
          ),
          _buildResumenRow(
            'Valor total en buseta',
            Helpers.formatearMoneda(valorTotal),
            destacado: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/mejora visual/stitch_inventario_m_vil_de_frituras/wallpaper.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFF8F3).withValues(alpha: 0.84),
                    const Color(0xFFFFF6EE).withValues(alpha: 0.7),
                    const Color(0xFFFFF5EC).withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _ReporteResumenTopBar(
                  onBack: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFE6A817),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 720),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildEncabezado(),
                                  _buildListaProductos(),
                                  _buildResumenNumerico(),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _compartirComoPdf,
                                      icon: const Icon(
                                        Icons.picture_as_pdf_rounded,
                                      ),
                                      label: Text(
                                        'Exportar PDF',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFE6A817,
                                        ),
                                        foregroundColor: const Color(
                                          0xFF29170C,
                                        ),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReporteResumenTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _ReporteResumenTopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B3B00).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Row(
            children: [
              Material(
                color: const Color(0xFFF3E5D0),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onBack,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF8C4F00),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'La Convicción',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF7C5800),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'RESUMEN REPORTE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.6,
                        color: const Color(0xFF8C4F00),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
