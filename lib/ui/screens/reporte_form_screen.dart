import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/utils/helpers.dart';
import '../../core/utils/session_manager.dart';
import '../../models/categoria.dart';
import '../../models/observador.dart';
import '../../models/producto.dart';
import '../../models/repartidor.dart';
import '../../models/reporte.dart';
import '../../providers/reporte_provider.dart';
import '../../services/categoria_service.dart';

class ReporteFormScreen extends StatefulWidget {
  final Reporte? reporte;

  const ReporteFormScreen({super.key, this.reporte});

  @override
  State<ReporteFormScreen> createState() => _ReporteFormScreenState();
}

class _ReporteFormScreenState extends State<ReporteFormScreen> {
  final CategoriaService _categoriaService = CategoriaService();
  bool get esEdicion => widget.reporte != null;
  DateTime _fechaSeleccionada = DateTime.now();

  Repartidor? _repartidorSeleccionado;
  Observador? _observadorSeleccionado;
  Map<int, Categoria> _categoriasPorId = {};

  final Map<int, TextEditingController> _traiaControllers = {};
  final Map<int, TextEditingController> _cargoControllers = {};
  final Map<int, TextEditingController> _quieroLlevarControllers = {};
  final Map<int, bool> _mostrarCalculadora = {};
  final Map<int, String?> _erroresQuieroLlevar = {};

  @override
  void initState() {
    super.initState();
    final provider = context.read<ReporteProvider>();

    Future.microtask(() async {
      await provider.cargarDatosBase();
      final categorias = await _categoriaService.listarCategorias();

      if (!mounted) return;

      setState(() {
        _categoriasPorId = {
          for (final categoria in categorias)
            if (categoria.idCategoria != null)
              categoria.idCategoria!: categoria,
        };
        if (provider.repartidores.isNotEmpty) {
          _repartidorSeleccionado = provider.repartidores.first;
        }

        for (final producto in provider.productos) {
          final idProducto = producto.idProducto!;
          _traiaControllers[idProducto] = TextEditingController(text: '0');
          _cargoControllers[idProducto] = TextEditingController(text: '0');
          _quieroLlevarControllers[idProducto] = TextEditingController();
          _mostrarCalculadora[idProducto] = false;
          _erroresQuieroLlevar[idProducto] = null;
        }
      });

      if (!esEdicion) return;

      final detalles = await provider.obtenerDetallesPorReporte(
        widget.reporte!.idReporte!,
      );

      if (!mounted) return;

      setState(() {
        for (final detalle in detalles) {
          final idProducto = detalle.idProducto;

          if (_traiaControllers.containsKey(idProducto)) {
            _traiaControllers[idProducto]!.text = Helpers.formatearCantidad(
              detalle.cantidadTraia,
            );
          }

          if (_cargoControllers.containsKey(idProducto)) {
            _cargoControllers[idProducto]!.text = Helpers.formatearCantidad(
              detalle.cantidadCargo,
            );
          }
        }

        _repartidorSeleccionado = provider.repartidores.firstWhere(
          (repartidor) =>
              repartidor.idRepartidor == widget.reporte!.idRepartidor,
          orElse: () => provider.repartidores.first,
        );

        _observadorSeleccionado = provider.observadores.firstWhere(
          (observador) =>
              observador.idObservador == widget.reporte!.idObservador,
          orElse: () => provider.observadores.first,
        );

        _fechaSeleccionada = DateTime.parse(widget.reporte!.fecha);
      });
    });
  }

  @override
  void dispose() {
    for (final controller in _traiaControllers.values) {
      controller.dispose();
    }
    for (final controller in _cargoControllers.values) {
      controller.dispose();
    }
    for (final controller in _quieroLlevarControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _formatearFecha(DateTime fecha) {
    return DateFormat('yyyy-MM-dd').format(fecha);
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

  double? _parseCantidad(String? valor) {
    if (valor == null) return null;

    final normalizado = valor.trim().replaceAll(',', '.');
    if (normalizado.isEmpty) return null;

    return double.tryParse(normalizado);
  }

  void _actualizarTextoController(
    TextEditingController controller,
    String texto,
  ) {
    controller.value = TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }

  void _recalcularCargoDesdeObjetivo(int idProducto) {
    final textoObjetivo = _quieroLlevarControllers[idProducto]?.text ?? '';
    final quieroLlevar = _parseCantidad(textoObjetivo);

    if (textoObjetivo.trim().isEmpty) {
      setState(() {
        _erroresQuieroLlevar[idProducto] = null;
      });
      return;
    }

    if (quieroLlevar == null) {
      setState(() {
        _erroresQuieroLlevar[idProducto] = 'Ingresa una cantidad valida.';
      });
      return;
    }

    final traia = _parseCantidad(_traiaControllers[idProducto]?.text) ?? 0;

    if (quieroLlevar < traia) {
      setState(() {
        _erroresQuieroLlevar[idProducto] =
            'No puede ser menor que lo que traía.';
      });
      return;
    }

    final cargoCalculado = quieroLlevar - traia;

    setState(() {
      _erroresQuieroLlevar[idProducto] = null;
      _actualizarTextoController(
        _cargoControllers[idProducto]!,
        Helpers.formatearCantidad(cargoCalculado),
      );
    });
  }

  void _toggleCalculadora(int idProducto) {
    setState(() {
      final estabaVisible = _mostrarCalculadora[idProducto] ?? false;
      _mostrarCalculadora[idProducto] = !estabaVisible;

      if (estabaVisible) {
        _quieroLlevarControllers[idProducto]?.clear();
        _erroresQuieroLlevar[idProducto] = null;
      }
    });
  }

  Future<void> _seleccionarFecha() async {
    final nuevaFecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      builder: (dialogContext, child) {
        return Theme(
          data: Theme.of(dialogContext).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE6A817),
              onPrimary: Color(0xFF29170C),
              surface: Colors.white,
              onSurface: Color(0xFF29170C),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (nuevaFecha == null) return;
    if (!mounted) return;

    setState(() {
      _fechaSeleccionada = nuevaFecha;
    });
  }

  Future<void> _guardarReporte() async {
    final provider = context.read<ReporteProvider>();
    final messenger = ScaffoldMessenger.of(context);

    if (_repartidorSeleccionado == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Selecciona un repartidor')),
      );
      return;
    }

    final cantidadesTraia = <int, double>{};
    final cantidadesCargo = <int, double>{};

    for (final producto in provider.productos) {
      final idProducto = producto.idProducto!;

      final textTraia =
          _traiaControllers[idProducto]?.text.trim().replaceAll(',', '.') ??
          '0';
      final textCargo =
          _cargoControllers[idProducto]?.text.trim().replaceAll(',', '.') ??
          '0';

      cantidadesTraia[idProducto] = double.tryParse(textTraia) ?? 0;
      cantidadesCargo[idProducto] = double.tryParse(textCargo) ?? 0;
    }

    provider.construirDetallesDesdeFormulario(
      productos: provider.productos,
      cantidadesTraia: cantidadesTraia,
      cantidadesCargo: cantidadesCargo,
    );

    bool ok = false;

    if (esEdicion) {
      final idEditor = SessionManager.idObservadorActual;

      if (idEditor == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No hay sesión activa')),
        );
        return;
      }

      ok = await provider.editarReporte(
        idReporte: widget.reporte!.idReporte!,
        idUltimoEditor: idEditor,
        fechaUltimaEdicion: _formatearFecha(DateTime.now()),
      );
    } else {
      final idObservadorActual = SessionManager.idObservadorActual;

      if (idObservadorActual == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('No hay sesión activa')),
        );
        return;
      }

      ok = await provider.guardarReporteCompleto(
        fecha: _formatearFecha(_fechaSeleccionada),
        idRepartidor: _repartidorSeleccionado!.idRepartidor!,
        idObservador: idObservadorActual,
      );
    }

    if (!mounted) return;

    if (ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Reporte guardado correctamente')),
      );

      provider.limpiarDetalles();
      await provider.cargarReportes();
      if (!mounted) return;
      Navigator.pop(context);
      return;
    }

    messenger.showSnackBar(
      const SnackBar(content: Text('Ocurrió un error al guardar el reporte')),
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required String hintText,
    IconData? icon,
    Color? fillColor,
    InputBorder? enabledBorder,
    InputBorder? focusedBorder,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: icon != null
          ? Icon(icon, color: const Color(0xFF8B7A63))
          : null,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF6B5C48),
      ),
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF9C8B74),
      ),
      filled: true,
      fillColor: fillColor ?? Colors.white.withValues(alpha: 0.72),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder:
          enabledBorder ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
          ),
      focusedBorder:
          focusedBorder ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE6A817), width: 1.4),
          ),
    );
  }

  Widget _buildSeccionTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        titulo,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.6,
          color: const Color(0xFF6B5C48),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
    bool showChevron = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6A817).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF8C4F00), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: const Color(0xFF6B5C48),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF29170C),
                      ),
                    ),
                  ],
                ),
              ),
              if (showChevron)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF8C4F00),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilaProducto(Producto producto) {
    final idProducto = producto.idProducto!;
    final mostrarCalculadora = _mostrarCalculadora[idProducto] ?? false;
    final errorQuieroLlevar = _erroresQuieroLlevar[idProducto];
    final colorCategoria = _colorCategoriaProducto(producto);
    final bordeQuieroLlevar = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(
        color: errorQuieroLlevar != null
            ? Colors.red
            : Colors.white.withValues(alpha: 0.18),
        width: errorQuieroLlevar != null ? 1.6 : 1,
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.48)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: colorCategoria,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  producto.nombre,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF29170C),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => _toggleCalculadora(idProducto),
                icon: Icon(
                  mostrarCalculadora
                      ? Icons.expand_less_rounded
                      : Icons.calculate_rounded,
                  size: 18,
                ),
                label: const Text('Ajustar a'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF8C4F00),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _traiaControllers[idProducto],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2A170C),
                  ),
                  onChanged: (_) {
                    if (_mostrarCalculadora[idProducto] ?? false) {
                      _recalcularCargoDesdeObjetivo(idProducto);
                    }
                  },
                  decoration: _inputDecoration(
                    labelText: 'Traía',
                    hintText: 'Cantidad',
                    fillColor: colorCategoria.withValues(alpha: 0.12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _cargoControllers[idProducto],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2A170C),
                  ),
                  decoration: _inputDecoration(
                    labelText: 'Cargó',
                    hintText: 'Cantidad',
                    fillColor: colorCategoria.withValues(alpha: 0.18),
                  ),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            child: mostrarCalculadora
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: TextField(
                      controller: _quieroLlevarControllers[idProducto],
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2A170C),
                      ),
                      onChanged: (_) =>
                          _recalcularCargoDesdeObjetivo(idProducto),
                      decoration: _inputDecoration(
                        labelText: 'Ajustar a',
                        hintText: 'Cantidad',
                        fillColor: colorCategoria.withValues(alpha: 0.14),
                        enabledBorder: bordeQuieroLlevar,
                        focusedBorder: bordeQuieroLlevar,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReporteProvider>();

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
                _ReporteFormTopBar(
                  onBack: () => Navigator.of(context).pop(),
                  esEdicion: esEdicion,
                ),
                Expanded(
                  child: provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFE6A817),
                            ),
                          ),
                        )
                      : provider.productos.isEmpty
                      ? const _ReporteFormEmptyState()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 720),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSeccionTitulo('DATOS'),
                                  _buildInfoTile(
                                    icon: Icons.calendar_month_rounded,
                                    label: 'Fecha',
                                    value: _formatearFecha(_fechaSeleccionada),
                                    onTap: esEdicion ? null : _seleccionarFecha,
                                    showChevron: !esEdicion,
                                  ),
                                  const SizedBox(height: 12),
                                  DropdownButtonFormField<Repartidor>(
                                    key: ValueKey(
                                      _repartidorSeleccionado?.idRepartidor,
                                    ),
                                    initialValue: _repartidorSeleccionado,
                                    dropdownColor: const Color(0xFFFFFCF8),
                                    icon: const Icon(
                                      Icons.expand_more_rounded,
                                      color: Color(0xFF8B7A63),
                                    ),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2A170C),
                                    ),
                                    decoration: _inputDecoration(
                                      labelText: 'Repartidor',
                                      hintText: 'Selecciona un repartidor',
                                      icon: Icons.local_shipping_rounded,
                                    ),
                                    items: provider.repartidores.map((
                                      repartidor,
                                    ) {
                                      return DropdownMenuItem(
                                        value: repartidor,
                                        child: Text(repartidor.nombre),
                                      );
                                    }).toList(),
                                    onChanged: esEdicion
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _repartidorSeleccionado = value;
                                            });
                                          },
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoTile(
                                    icon: Icons.visibility_rounded,
                                    label: 'Observador',
                                    value: esEdicion
                                        ? (_observadorSeleccionado?.nombre ??
                                              'No encontrado')
                                        : (SessionManager
                                                  .nombreObservadorActual ??
                                              'No hay sesión'),
                                  ),
                                  const SizedBox(height: 24),
                                  _buildSeccionTitulo('PRODUCTOS'),
                                  for (final producto in provider.productos)
                                    _buildFilaProducto(producto),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: provider.guardando
                                          ? null
                                          : _guardarReporte,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFE6A817,
                                        ),
                                        foregroundColor: const Color(
                                          0xFF29170C,
                                        ),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                        ),
                                      ),
                                      child: provider.guardando
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Color(0xFF29170C)),
                                              ),
                                            )
                                          : Text(
                                              esEdicion
                                                  ? 'Guardar cambios'
                                                  : 'Guardar reporte',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
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

class _ReporteFormTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final bool esEdicion;

  const _ReporteFormTopBar({required this.onBack, required this.esEdicion});

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
                      esEdicion ? 'EDITAR REPORTE' : 'NUEVO REPORTE',
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

class _ReporteFormEmptyState extends StatelessWidget {
  const _ReporteFormEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 720),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.68),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6A817).withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 34,
                  color: Color(0xFFB88612),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No hay productos registrados',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF29170C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
