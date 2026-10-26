import 'package:hive/hive.dart';

import '../models/gasto.dart';
import '../services/api_exception.dart';
import '../services/gastos_api_service.dart';

/// Decide de dónde salen los gastos — Sesión 7. Quien lo usa (el
/// controller) pide «mis gastos» sin saber si vinieron del backend o de la
/// copia local: primero intenta el servidor y, solo si falla por red o por
/// el propio servidor, devuelve la última copia guardada en Hive.
///
/// Decisiones (se pueden justificar en clase):
/// - Cada usuario tiene su propia caja, `gastos_<id>`: los gastos son datos
///   personales y Hive guarda **sin cifrar** en el almacenamiento de la app.
/// - La caja se borra al cerrar sesión (`vaciar`).
/// - Un 401 (sesión caducada) o un 400/403/404 **no** usan la caché: no son
///   fallas de infraestructura y esconderlas con datos viejos confundiría.
/// - La caché es de **lectura**: un gasto creado sin red no existe en el
///   servidor (se retoma en la Sesión 8).
/// - El token **no** se guarda aquí: sigue solo en memoria.
class GastosRepository {
  GastosRepository(this._api);

  final GastosApiService _api;
  Box? _caja;

  static const _claveGastos = 'gastos';
  static const _claveSincronizado = 'sincronizado';

  /// Abre (o crea) la caja del usuario que acaba de iniciar sesión. El id sale
  /// de `GET /usuarios/me`, no del correo escrito en el formulario.
  Future<void> abrirParaUsuario() async {
    final id = await _api.obtenerIdUsuario();
    _caja = await Hive.openBox('gastos_$id');
  }

  /// Devuelve la lista y un indicador: `true` si viene de la caché (respaldo).
  Future<(List<Gasto>, bool)> obtenerGastos() async {
    try {
      // `limit: 100` es el máximo del backend; la caché no se pagina.
      final resultado = await _api.listarGastos(limit: 100);
      await _guardar(resultado.gastos);
      return (resultado.gastos, false);
    } on ApiException catch (e) {
      final fallaDeInfraestructura = e.statusCode == null || e.statusCode! >= 500;
      if (!fallaDeInfraestructura) rethrow;
      final guardados = _leer();
      if (guardados == null) rethrow;
      return (guardados, true);
    }
  }

  /// Fecha y hora de la última carga exitosa, lista para mostrar.
  String get ultimaSincronizacion {
    final iso = _caja?.get(_claveSincronizado) as String?;
    final fecha = iso == null ? null : DateTime.tryParse(iso)?.toLocal();
    if (fecha == null) return 'desconocida';
    String dos(int n) => n.toString().padLeft(2, '0');
    return '${dos(fecha.day)}/${dos(fecha.month)} ${dos(fecha.hour)}:${dos(fecha.minute)}';
  }

  /// Cierra y borra del disco la caja del usuario (se llama al cerrar sesión).
  Future<void> vaciar() async {
    await _caja?.deleteFromDisk();
    _caja = null;
  }

  Future<void> _guardar(List<Gasto> gastos) async {
    final caja = _caja;
    if (caja == null) return;
    // Cada carga exitosa REEMPLAZA la copia anterior: la caché refleja lo
    // último que dijo el servidor, sin arrastrar gastos que ya no existen.
    await caja.put(_claveGastos, gastos.map((g) => g.toMap()).toList());
    await caja.put(_claveSincronizado, DateTime.now().toIso8601String());
  }

  List<Gasto>? _leer() {
    // Un 401 cierra la sesión (y la caja) mientras esta lectura sigue en marcha.
    final caja = _caja;
    if (caja == null || !caja.isOpen) return null;
    final guardado = caja.get(_claveGastos);
    if (guardado is! List) return null;
    return guardado.map((m) => Gasto.fromMap(m as Map)).toList();
  }
}
