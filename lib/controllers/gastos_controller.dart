import 'package:get/get.dart';

import '../models/gasto.dart';
import '../repositories/gastos_repository.dart';
import '../services/api_exception.dart';
import '../services/gastos_api_service.dart';
import 'places_controller.dart' show EstadoCarga;

/// Estado de la sección Gastos (patrón de la Sesión 4: el controller guarda
/// el estado y `Obx` reconstruye la pantalla). Reutiliza `EstadoCarga`; el
/// "vacío" se deriva de `gastos.isEmpty` con estado `exito`. Desde la
/// Sesión 7 los gastos pasan por `GastosRepository` (servidor primero,
/// caché de Hive como respaldo).
class GastosController extends GetxController {
  static const int _tamanoPagina = 20;

  final GastosApiService _api = GastosApiService();
  late final GastosRepository _repository = GastosRepository(_api);

  final RxList<Gasto> gastos = <Gasto>[].obs;
  final Rx<EstadoCarga> estado = EstadoCarga.exito.obs;
  final RxString mensajeError = ''.obs;
  final RxInt totalEnServidor = 0.obs;

  /// `true` solo cuando la última carga exitosa vino de la caché local (el
  /// servidor no respondió): la UI lo usa para avisar «datos guardados».
  final RxBool desdeCache = false.obs;
  String get ultimaSincronizacion => _repository.ultimaSincronizacion;

  final RxBool sesionActiva = false.obs;
  final RxBool autenticando = false.obs;
  final RxString mensajeAuth = ''.obs;

  bool get hayMas => gastos.length < totalEnServidor.value;

  Future<void> entrar(String email, String password) async {
    autenticando.value = true;
    mensajeAuth.value = '';

    // TODO(sesion-06): borra las dos líneas de abajo y descomenta el bloque completo. (Paso 7 — flujo asíncrono)
    // Por qué: registro -> login -> listar dependen uno del otro; `await`
    // permite escribirlos en orden. Un 400 en el registro significa "el
    // correo ya existe": se ignora y se sigue al login.
    try {
      try {
        await _api.registrar(email, password);
      } on ApiException catch (e) {
        if (e.statusCode != 400) rethrow;
      }
      await _api.login(email, password);
      await _repository.abrirParaUsuario(); // Sesión 7: caja `gastos_<id>`
      sesionActiva.value = true;
      await cargarGastos();
    } on ApiException catch (e) {
      mensajeAuth.value = e.mensaje;
    } catch (e) {
      mensajeAuth.value = 'Error inesperado: $e';
    } finally {
      autenticando.value = false;
    }
  }

  Future<void> cargarGastos() async {
    estado.value = EstadoCarga.cargando;

    // TODO(sesion-06): borra las dos líneas de abajo y descomenta el bloque completo. (Paso 7 — listar gastos)
    // Por qué: las 2 líneas fuerzan éxito con lista vacía, sin llamar a nada.
    // El bloque real traduce el resultado -o la excepción- a los mismos 3
    // estados de siempre; un 401 devuelve al formulario.
    try {
      // TODO(sesion-07): borra el bloque de abajo (desde `final resultado` hasta `estado.value = EstadoCarga.exito;`) y descomenta el bloque completo. (Paso 2 — repositorio con caché)
      // Por qué: el bloque de abajo llama al servicio directo, igual que en la
      // Sesión 6: sin red, la carga falla sin más. El bloque real pide los
      // gastos al repositorio, que primero intenta el servidor y, si falla por
      // red o por el propio servidor, devuelve la última copia guardada en Hive
      // (y `desdeCache` pasa a `true` para que la pantalla lo avise).

      final (lista, cache) = await _repository.obtenerGastos();
      gastos.value = lista;
      totalEnServidor.value = lista.length;
      desdeCache.value = cache;
      estado.value = EstadoCarga.exito;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        sesionActiva.value = false; // volver al formulario
        mensajeAuth.value = e.mensaje; // y explicar por qué
      }
      mensajeError.value = e.mensaje;
      estado.value = EstadoCarga.error;
    } catch (e) {
      mensajeError.value = 'Error inesperado: $e';
      estado.value = EstadoCarga.error;
    }
  }

  /// Siguiente página (skip = lo ya cargado). No cambia `estado`: el error
  /// de esta carga se avisa con un snackbar para no tapar la lista.
  Future<void> cargarMas() async {
    if (!hayMas) return;
    try {
      final r =
          await _api.listarGastos(skip: gastos.length, limit: _tamanoPagina);
      gastos.addAll(r.gastos);
      totalEnServidor.value = r.total;
    } on ApiException catch (e) {
      Get.snackbar('No se pudo cargar más', e.mensaje);
    }
  }

  // TODO(sesion-07): borra el método `salir` de abajo (la versión de la Sesión 6) y descomenta el bloque completo. (Paso 5 — cerrar sesión)
  // Por qué: la versión de abajo solo olvida el token en memoria: la caja de
  // Hive de este usuario seguiría en el disco del teléfono (sin cifrar). La
  // versión real además la cierra y la borra (`vaciar`), para que otra
  // persona que use el mismo teléfono no pueda ver estos gastos.

  Future<void> salir() async {
    _api.cerrarSesion();
    await _repository.vaciar();
    gastos.clear();
    totalEnServidor.value = 0;
    desdeCache.value = false;
    estado.value = EstadoCarga.exito;
    sesionActiva.value = false;
  }

  /// Solo práctica (Paso 8): la siguiente petición responderá 401.
  void invalidarTokenParaPruebas() => _api.invalidarTokenParaPruebas();
}
