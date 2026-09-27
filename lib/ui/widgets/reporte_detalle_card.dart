import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/utils/helpers.dart';

class ReporteDetalleCard extends StatelessWidget {
  final String nombreProducto;
  final double cantidadTraia;
  final double cantidadCargo;
  final double totalProducto;
  final Color colorCategoria;

  const ReporteDetalleCard({
    super.key,
    required this.nombreProducto,
    required this.cantidadTraia,
    required this.cantidadCargo,
    required this.totalProducto,
    required this.colorCategoria,
  });

  Widget _buildCantidad(String label, String valor, {bool destacado = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B5C48),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: GoogleFonts.plusJakartaSans(
              fontSize: destacado ? 15 : 14,
              fontWeight: destacado ? FontWeight.w800 : FontWeight.w700,
              color: destacado
                  ? const Color(0xFF8C4F00)
                  : const Color(0xFF29170C),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colorCategoria.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  size: 16,
                  color: Color(0xFF8C4F00),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  nombreProducto,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF29170C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
            decoration: BoxDecoration(
              color: colorCategoria.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                _buildCantidad(
                  'Traía',
                  Helpers.formatearCantidad(cantidadTraia),
                ),
                Container(width: 1, height: 30, color: const Color(0xFFE3D3BA)),
                _buildCantidad(
                  'Cargó',
                  Helpers.formatearCantidad(cantidadCargo),
                ),
                Container(width: 1, height: 30, color: const Color(0xFFE3D3BA)),
                _buildCantidad(
                  'Total',
                  Helpers.formatearCantidad(totalProducto),
                  destacado: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
