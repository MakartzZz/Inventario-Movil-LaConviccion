import 'package:flutter/material.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/productos_screen.dart';
import '../ui/screens/reporte_screen.dart';
import '../ui/screens/login_screen.dart';
import '../ui/screens/reporte_form_screen.dart';
import '../ui/screens/repartidores_screen.dart';
import '../ui/screens/observadores_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String productos = '/productos';
  static const String reportes = '/reportes';
  static const String login = '/login';
  static const String reporteForm = '/reporte_form';
  static const String repartidores = '/repartidores';
  static const String observadores = '/observadores';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    productos: (context) => const ProductosScreen(),
    reportes: (context) => const ReporteScreen(),
    login: (context) => const LoginScreen(),
    reporteForm: (context) => const ReporteFormScreen(),
    repartidores: (context) => const RepartidoresScreen(),
    observadores: (context) => const ObservadoresScreen(),
  };
}
