import 'package:intl/intl.dart';

class Helpers {
  static String formatearFecha(DateTime fecha) {
    return DateFormat('yyyy-MM-dd').format(fecha);
  }

  static bool validarPin(String pin) {
    final regex = RegExp(r'^\d{4}$');
    return regex.hasMatch(pin);
  }

  static int parseEntero(String? valor, {int defaultValue = 0}) {
    if (valor == null || valor.trim().isEmpty) {
      return defaultValue;
    }

    return int.tryParse(valor.trim()) ?? defaultValue;
  }

  static double parseDouble(String? valor, {double defaultValue = 0.0}) {
    if (valor == null || valor.trim().isEmpty) {
      return defaultValue;
    }

    return double.tryParse(valor.trim()) ?? defaultValue;
  }

  static String formatearMoneda(double valor) {
    final formato = NumberFormat.currency(
      locale: 'es_CR',
      symbol: '₡',
      decimalDigits: 2,
    );

    return formato.format(valor);
  }

  static String formatearMonedaPdf(double valor) {
    final formato = NumberFormat.currency(
      locale: 'es_CR',
      symbol: 'Colones. ',
      decimalDigits: 2,
    );

    return formato.format(valor);
  }

  static bool textoNoVacio(String? valor) {
    return valor != null && valor.trim().isNotEmpty;
  }

  static String formatearCantidad(double valor) {
    if (valor % 1 == 0) {
      return valor.toInt().toString();
    } else {
      return valor.toString();
    }
  }
}
