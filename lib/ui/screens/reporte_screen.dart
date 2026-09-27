import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/reporte.dart';
import '../../providers/reporte_provider.dart';
import '../../routes/app_routes.dart';
import '../widgets/reporte_card.dart';
import 'reporte_form_screen.dart';
import 'reporte_resumen_screen.dart';

class ReporteScreen extends StatefulWidget {
  const ReporteScreen({super.key});

  @override
  State<ReporteScreen> createState() => _ReporteScreenState();
}

class _ReporteScreenState extends State<ReporteScreen> {
  DateTime? _fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ReporteProvider>().cargarReportes();
    });
  }

  String _formatearFecha(DateTime fecha) {
    return DateFormat('yyyy-MM-dd').format(fecha);
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? nuevaFecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
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

    await context.read<ReporteProvider>().filtrarPorFecha(
      _formatearFecha(nuevaFecha),
    );
  }

  Future<void> _limpiarFiltro() async {
    setState(() {
      _fechaSeleccionada = null;
    });
    await context.read<ReporteProvider>().limpiarFiltro();
  }

  void _irACrearReporte() {
    Navigator.pushNamed(context, AppRoutes.reporteForm);
  }

  Future<void> _irADetalle(Reporte reporte) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReporteResumenScreen(reporte: reporte)),
    );
    if (!mounted) return;
    await context.read<ReporteProvider>().cargarReportes();
  }

  Future<void> _editarReporte(Reporte reporte) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReporteFormScreen(reporte: reporte)),
    );
    if (!mounted) return;
    await context.read<ReporteProvider>().cargarReportes();
  }

  Future<void> _eliminarReporte(Reporte reporte) async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 24,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.14),
                      blurRadius: 28,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: Colors.red,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Eliminar reporte',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF29170C),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2C1A0E),
                          height: 1.45,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Deseas eliminar el reporte del ',
                          ),
                          TextSpan(
                            text: reporte.fecha,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const TextSpan(
                            text: '? Esta acción no se puede deshacer.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF6B4226),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              'Eliminar',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (confirmar != true) return;
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<ReporteProvider>().eliminarReporte(
      reporte.idReporte!,
    );

    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Reporte eliminado correctamente'
              : 'Error al eliminar el reporte',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReporteProvider>();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _irACrearReporte,
        backgroundColor: const Color(0xFFE6A817),
        foregroundColor: const Color(0xFF29170C),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Nuevo reporte',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
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
                _ReportesTopBar(
                  onBack: () => Navigator.of(context).pop(),
                  onCalendarTap: _seleccionarFecha,
                  filtroActivo: _fechaSeleccionada != null
                      ? _formatearFecha(_fechaSeleccionada!)
                      : null,
                  onClearFilter: _limpiarFiltro,
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
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(18, 24, 18, 118),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 720),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reportes',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF29170C),
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _fechaSeleccionada != null
                                        ? 'Mostrando los reportes del dia filtrado.'
                                        : 'Consulta, edita o elimina los cierres registrados.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF5F5140),
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  if (provider.reportes.isEmpty)
                                    _EmptyState(
                                      hayFiltro: _fechaSeleccionada != null,
                                      onClearFilter: _limpiarFiltro,
                                    )
                                  else
                                    Column(
                                      children: [
                                        for (final reporte
                                            in provider.reportes) ...[
                                          ReporteCard(
                                            reporte: reporte,
                                            onTap: () => _irADetalle(reporte),
                                            onEditar: () =>
                                                _editarReporte(reporte),
                                            onEliminar: () =>
                                                _eliminarReporte(reporte),
                                          ),
                                          const SizedBox(height: 18),
                                        ],
                                      ],
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

class _ReportesTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onCalendarTap;
  final VoidCallback onClearFilter;
  final String? filtroActivo;

  const _ReportesTopBar({
    required this.onBack,
    required this.onCalendarTap,
    required this.onClearFilter,
    required this.filtroActivo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF6B3B00).withValues(alpha: 0.08),
          ),
        ),
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
                      'REPORTES',
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
              const SizedBox(width: 10),
              if (filtroActivo != null) ...[
                _FilterChip(label: filtroActivo!, onTap: onClearFilter),
                const SizedBox(width: 8),
              ],
              Material(
                color: const Color(0xFFF3E5D0),
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onCalendarTap,
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: Color(0xFF8C4F00),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3E5D0),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8C4F00),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.close_rounded,
                size: 14,
                color: Color(0xFF8C4F00),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hayFiltro;
  final VoidCallback onClearFilter;

  const _EmptyState({required this.hayFiltro, required this.onClearFilter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: const Color(0xFFE6A817).withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hayFiltro ? Icons.search_off_rounded : Icons.description_outlined,
              size: 34,
              color: const Color(0xFFB88612),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hayFiltro
                ? 'No hay reportes para esa fecha'
                : 'No hay reportes registrados',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF29170C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hayFiltro
                ? 'Prueba con otra fecha o limpia el filtro.'
                : 'Crea el primero para empezar a registrar la operación diaria.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B5C48),
            ),
          ),
          if (hayFiltro) ...[
            const SizedBox(height: 18),
            TextButton(
              onPressed: onClearFilter,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8C4F00),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Limpiar filtro',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
