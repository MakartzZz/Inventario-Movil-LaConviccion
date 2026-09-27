import 'package:flutter/material.dart';
import 'package:inv_movil_laconviccion/providers/reporte_provider.dart';
import 'package:provider/provider.dart';
import 'package:inv_movil_laconviccion/database/database_helper.dart';
import 'package:inv_movil_laconviccion/providers/producto_provider.dart';
import 'package:inv_movil_laconviccion/providers/repartidor_provider.dart';
import 'package:inv_movil_laconviccion/providers/observador_provider.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

//Temporal:
import 'package:inv_movil_laconviccion/models/observador.dart';
import 'package:inv_movil_laconviccion/models/repartidor.dart';
import 'package:inv_movil_laconviccion/services/reporte_service.dart';

Future<void> _insertarDatosIniciales() async {
  final reporteService = ReporteService();

  final observadores = await reporteService.listarObservadores();
  if (observadores.isEmpty) {
    await reporteService.guardarObservador(
      Observador(nombre: 'TempUser', pin: '1234'),
    );
  }

  final repartidores = await reporteService.listarRepartidores();
  if (repartidores.isEmpty) {
    await reporteService.guardarRepartidor(Repartidor(nombre: 'TempDriver'));
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseHelper.instance.database;
  await _insertarDatosIniciales();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductoProvider()),
        ChangeNotifierProvider(create: (_) => ReporteProvider()),
        ChangeNotifierProvider(create: (_) => RepartidorProvider()),
        ChangeNotifierProvider(create: (_) => ObservadorProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Control Reparto',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
      ),
    );
  }
}
