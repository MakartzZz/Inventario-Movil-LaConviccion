import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/repartidor.dart';
import '../models/observador.dart';
import '../models/reporte.dart';
import '../models/reporte_detalle.dart';

class ReporteService {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  //AGREGAR REPARTIDOR
  Future<int> guardarRepartidor(Repartidor repartidor) async {
    final Database db = await _databaseHelper.database;

    final data = repartidor.toMap();
    data.remove('id_repartidor');

    return await db.insert('LC_repartidores', data);
  }

  //LISTAR REPARTIDORES
  Future<List<Repartidor>> listarRepartidores() async {
    final Database db = await _databaseHelper.database;

    final result = await db.query('LC_repartidores', orderBy: 'nombre ASC');

    return result.map((map) => Repartidor.fromMap(map)).toList();
  }

  //AGREGAR OBSERVADOR
  Future<int> guardarObservador(Observador observador) async {
    final Database db = await _databaseHelper.database;

    final data = observador.toMap();
    data.remove('id_observador');

    return await db.insert('LC_observadores', data);
  }

  //LISTAR OBSERVADORES
  Future<List<Observador>> listarObservadores() async {
    final Database db = await _databaseHelper.database;

    final result = await db.query('LC_observadores', orderBy: 'nombre ASC');

    return result.map((map) => Observador.fromMap(map)).toList();
  }

  //LOGIN OBSERVADOR
  Future<Observador?> loginObservador({
    required String nombre,
    required String pin,
  }) async {
    final Database db = await _databaseHelper.database;

    final result = await db.query(
      'LC_observadores',
      where: 'nombre = ? AND pin = ?',
      whereArgs: [nombre, pin],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return Observador.fromMap(result.first);
  }

  // ==============================
  // NUEVO: CREAR REPORTE
  // ==============================
  Future<int> crearReporte(Reporte reporte) async {
    final Database db = await _databaseHelper.database;

    final data = reporte.toMap();
    data.remove('id_reporte');

    return await db.insert('LC_reportes', data);
  }

  // ==============================
  // NUEVO: GUARDAR DETALLE
  // ==============================
  Future<int> guardarDetalleReporte(ReporteDetalle detalle) async {
    final Database db = await _databaseHelper.database;

    final data = detalle.toMap();
    data.remove('id_detalle');

    return await db.insert('LC_reporte_detalle', data);
  }

  // ==============================
  // NUEVO: GUARDAR REPORTE COMPLETO
  // ==============================
  Future<int> guardarReporteCompleto({
    required Reporte reporte,
    required List<ReporteDetalle> detalles,
  }) async {
    final Database db = await _databaseHelper.database;

    return await db.transaction((txn) async {
      final reporteData = reporte.toMap();
      reporteData.remove('id_reporte');

      final int idReporte = await txn.insert('LC_reportes', reporteData);

      for (final detalle in detalles) {
        final detalleData = detalle.toMap();
        detalleData.remove('id_detalle');
        detalleData['id_reporte'] = idReporte;

        await txn.insert('LC_reporte_detalle', detalleData);
      }

      return idReporte;
    });
  }

  // ==============================
  // NUEVO: OBTENER REPORTES POR FECHA
  // ==============================
  Future<List<Reporte>> obtenerReportesPorFecha(String fecha) async {
    final Database db = await _databaseHelper.database;

    final result = await db.query(
      'LC_reportes',
      where: 'fecha = ?',
      whereArgs: [fecha],
      orderBy: 'id_reporte DESC',
    );

    return result.map((map) => Reporte.fromMap(map)).toList();
  }

  // ==============================
  // NUEVO: OBTENER DETALLES POR REPORTE
  // ==============================
  Future<List<ReporteDetalle>> obtenerDetallesPorReporte(int idReporte) async {
    final Database db = await _databaseHelper.database;

    final result = await db.query(
      'LC_reporte_detalle',
      where: 'id_reporte = ?',
      whereArgs: [idReporte],
      orderBy: 'id_detalle ASC',
    );

    return result.map((map) => ReporteDetalle.fromMap(map)).toList();
  }

  // NUEVO: LISTAR
  Future<List<Reporte>> listarReportes() async {
    final Database db = await _databaseHelper.database;

    final result = await db.query(
      'LC_reportes',
      orderBy: 'fecha DESC, id_reporte DESC',
    );

    return result.map((map) => Reporte.fromMap(map)).toList();
  }

  // NUEVO: LISTAR POR FECHA
  Future<List<Reporte>> listarReportesPorFecha(String fecha) async {
    final Database db = await _databaseHelper.database;

    final result = await db.query(
      'LC_reportes',
      where: 'fecha = ?',
      whereArgs: [fecha],
      orderBy: 'id_reporte DESC',
    );

    return result.map((map) => Reporte.fromMap(map)).toList();
  }

  // NUEVO: OBTENER POR ID
  Future<Reporte?> obtenerReportePorId(int idReporte) async {
    final Database db = await _databaseHelper.database;

    final result = await db.query(
      'LC_reportes',
      where: 'id_reporte = ?',
      whereArgs: [idReporte],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return Reporte.fromMap(result.first);
  }

  // EDITAR REPORTE COMPLETO
  Future<void> editarReporteCompleto({
    required int idReporte,
    required int idUltimoEditor,
    required String fechaUltimaEdicion,
    required List<ReporteDetalle> detalles,
  }) async {
    final Database db = await _databaseHelper.database;

    await db.transaction((txn) async {
      await txn.update(
        'LC_reportes',
        {
          'id_ultimo_editor': idUltimoEditor,
          'fecha_ultima_edicion': fechaUltimaEdicion,
        },
        where: 'id_reporte = ?',
        whereArgs: [idReporte],
      );

      await txn.delete(
        'LC_reporte_detalle',
        where: 'id_reporte = ?',
        whereArgs: [idReporte],
      );

      for (final detalle in detalles) {
        final detalleData = detalle.toMap();
        detalleData.remove('id_detalle');
        detalleData['id_reporte'] = idReporte;

        await txn.insert('LC_reporte_detalle', detalleData);
      }
    });
  }

  //EDITAR REPARTIDOR
  Future<int> editarRepartidor(Repartidor repartidor) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'LC_repartidores',
      repartidor.toMap(),
      where: 'id_repartidor = ?',
      whereArgs: [repartidor.idRepartidor],
    );
  }

  //EDITAR OBSERVADOR
  Future<int> editarObservador(Observador observador) async {
    final db = await DatabaseHelper.instance.database;

    return await db.update(
      'LC_observadores',
      observador.toMap(),
      where: 'id_observador = ?',
      whereArgs: [observador.idObservador],
    );
  }

  Future<void> eliminarReporte(int idReporte) async {
    final Database db = await _databaseHelper.database;

    await db.transaction((txn) async {
      await txn.delete(
        'LC_reporte_detalle',
        where: 'id_reporte = ?',
        whereArgs: [idReporte],
      );

      await txn.delete(
        'LC_reportes',
        where: 'id_reporte = ?',
        whereArgs: [idReporte],
      );
    });
  }

  Future<bool> eliminarObservador(int idObservador) async {
    final Database db = await _databaseHelper.database;

    // Verificar si está como observador original en algún reporte
    final comoObservador = await db.query(
      'LC_reportes',
      where: 'id_observador = ?',
      whereArgs: [idObservador],
      limit: 1,
    );

    if (comoObservador.isNotEmpty) return false;

    // Verificar si está como último editor en algún reporte
    final comoEditor = await db.query(
      'LC_reportes',
      where: 'id_ultimo_editor = ?',
      whereArgs: [idObservador],
      limit: 1,
    );

    if (comoEditor.isNotEmpty) return false;

    await db.delete(
      'LC_observadores',
      where: 'id_observador = ?',
      whereArgs: [idObservador],
    );

    return true;
  }
}
