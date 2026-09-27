import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/utils/session_manager.dart';
import '../../routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nombre = SessionManager.nombreObservadorActual ?? 'Usuario';

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
                _HomeTopBar(
                  onLogout: () {
                    SessionManager.cerrarSesion();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 24, 18, 32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _WelcomeSection(nombre: nombre),
                            const SizedBox(height: 28),
                            _MenuActionCard(
                              title: 'Reportes',
                              description:
                                  'Inventario diario y Reportes de inventarios anteriores',
                              icon: Icons.bar_chart_rounded,
                              watermarkIcon: Icons.bar_chart_rounded,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.reportes,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _MenuActionCard(
                              title: 'Productos & Categorías',
                              description: 'Gestionar productos y categorías',
                              icon: Icons.inventory_2_rounded,
                              watermarkIcon: Icons.inventory_2_rounded,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.productos,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _MenuActionCard(
                              title: 'Repartidores',
                              description:
                                  'Registra, edita o elimina proveedores',
                              icon: Icons.local_shipping_rounded,
                              watermarkIcon: Icons.local_shipping_rounded,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.repartidores,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _MenuActionCard(
                              title: 'Observadores',
                              description:
                                  'Registra, edita o elimina observadores',
                              icon: Icons.visibility_rounded,
                              watermarkIcon: Icons.visibility_rounded,
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.observadores,
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

class _HomeTopBar extends StatelessWidget {
  final VoidCallback onLogout;

  const _HomeTopBar({required this.onLogout});

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
              Expanded(child: _buildBrandBlock()),
              const SizedBox(width: 12),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _buildLogoutButton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'La Convicción',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF7C5800),
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'CONTROL REPARTO',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.6,
              color: const Color(0xFF8C4F00),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Material(
      color: const Color(0xFFF3E5D0),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onLogout,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'Cerrar sesión',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8C4F00),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.logout_rounded,
                color: Color(0xFF8C4F00),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  final String nombre;

  const _WelcomeSection({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'lib/mejora visual/stitch_inventario_m_vil_de_frituras/panel_de_control_marca_la_convicci_n/pet.gif',
            width: 65,
            height: 65,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Hola, $nombre!',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF29170C),
                  letterSpacing: -0.8,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '¿Que deseas gestionar hoy?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5F5140),
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final IconData watermarkIcon;
  final VoidCallback onTap;

  const _MenuActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.watermarkIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE6A817), Color(0xFFB88612)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB88612).withValues(alpha: 0.28),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -18,
                bottom: -18,
                child: Transform.rotate(
                  angle: -0.18,
                  child: Icon(
                    watermarkIcon,
                    size: 170,
                    color: const Color(0xFF29170C).withValues(alpha: 0.11),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 24,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFF29170C).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        icon,
                        size: 34,
                        color: const Color(0xFF29170C),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF29170C),
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(
                                0xFF3F2A14,
                              ).withValues(alpha: 0.78),
                              height: 1.35,
                            ),
                          ),
                        ],
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
