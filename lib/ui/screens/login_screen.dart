import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/utils/session_manager.dart';
import '../../models/observador.dart';
import '../../routes/app_routes.dart';
import '../../services/reporte_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ReporteService _reporteService = ReporteService();
  final TextEditingController _pinController = TextEditingController();

  List<Observador> _observadores = [];
  Observador? _observadorSeleccionado;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _obscurePin = true;

  @override
  void initState() {
    super.initState();
    _cargarObservadores();
  }

  Future<void> _cargarObservadores() async {
    final observadores = await _reporteService.listarObservadores();
    if (!mounted) return;

    setState(() {
      _observadores = observadores;
      if (observadores.isNotEmpty) {
        _observadorSeleccionado = observadores.first;
      }
      _isLoading = false;
    });
  }

  Future<void> _iniciarSesion() async {
    final messenger = ScaffoldMessenger.of(context);
    final pin = _pinController.text.trim();

    if (_observadorSeleccionado == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Selecciona un observador')),
      );
      return;
    }

    if (pin.length != 4) {
      messenger.showSnackBar(
        const SnackBar(content: Text('El PIN debe tener 4 dígitos')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final observador = await _reporteService.loginObservador(
        nombre: _observadorSeleccionado!.nombre,
        pin: pin,
      );

      if (!mounted) return;

      if (observador == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Nombre o PIN incorrecto')),
        );
        return;
      }

      SessionManager.iniciarSesion(observador);
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: const Color(0xFF6B5C48),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.5),
      prefixIcon: Icon(icon, color: const Color(0xFF8B7A63)),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFE6A817), width: 1.4),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.2),
                blurRadius: 30,
              ),
            ],
          ),
          child: const Icon(
            Icons.local_shipping_rounded,
            size: 42,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'CONTROL REPARTO',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 4.2,
            color: Colors.white.withValues(alpha: 0.92),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'La Convicción',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 43,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            height: 1.02,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Inicia sesión para continuar',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF3D8A4),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF8B5E1A),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'No hay observadores registrados.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D1A0F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.68),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Observador',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: const Color(0xFF6B5C48),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Observador>(
                initialValue: _observadorSeleccionado,
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
                  label: '',
                  icon: Icons.person_rounded,
                ),
                items: _observadores.map((observador) {
                  return DropdownMenuItem(
                    value: observador,
                    child: Text(observador.nombre),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _observadorSeleccionado = value;
                  });
                },
              ),
              const SizedBox(height: 18),
              Text(
                'PIN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: const Color(0xFF6B5C48),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: _obscurePin,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2A170C),
                ),
                decoration:
                    _inputDecoration(
                      label: '',
                      icon: Icons.lock_rounded,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePin = !_obscurePin;
                          });
                        },
                        icon: Icon(
                          _obscurePin
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: const Color(0xFF8B7A63),
                        ),
                      ),
                    ).copyWith(
                      hintText: '\u2022\u2022\u2022\u2022',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9C8B74),
                        letterSpacing: 3,
                      ),
                      counterText: '',
                    ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _iniciarSesion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE6A817),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSubmitting) ...[
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'CARGANDO...',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'INGRESAR',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.login_rounded, size: 18),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
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
                      Colors.black.withValues(alpha: 0.12),
                      Colors.black.withValues(alpha: 0.24),
                      Colors.black.withValues(alpha: 0.56),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 24,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 410),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildBrandHeader(),
                        const SizedBox(height: 28),
                        if (_isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 36),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFE6A817),
                              ),
                            ),
                          )
                        else if (_observadores.isEmpty)
                          _buildEmptyState()
                        else
                          _buildFormCard(),
                        const SizedBox(height: 26),
                        Text(
                          'v1.2.0',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                            color: Colors.white.withValues(alpha: 0.54),
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
    );
  }
}
