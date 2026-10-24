import 'package:get/get.dart';

import '../models/gasto.dart';
import '../services/api_exception.dart';
import '../services/gastos_api_service.dart';
import 'places_controller.dart' show EstadoCarga;

/// Estado de la sección Gastos (patrón de la Sesión 4: el controller guarda
/// el estado y `Obx` reconstruye la pantalla). Reutiliza `EstadoCarga`; el
/// "vacío" se deriva de `gastos.isEmpty` con estado `exito`.
class GastosController extends GetxController {
  static const int _tamanoPagina = 20;

  final GastosApiService _api = GastosApiService();

  final RxList<Gasto> gastos = <Gasto>[].obs;
  final Rx<EstadoCarga> estado = EstadoCarga.exito.obs;
  final RxString mensajeError = ''.obs;
  final RxInt totalEnServidor = 0.obs;

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
      final resultado = await _api.listarGastos(skip: 0, limit: _tamanoPagina);
      gastos.value = resultado.gastos;
      totalEnServidor.value = resultado.total;
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

  void salir() {
    _api.cerrarSesion();
    gastos.clear();
    totalEnServidor.value = 0;
    estado.value = EstadoCarga.exito;
    sesionActiva.value = false;
  }

  /// Solo práctica (Paso 8): la siguiente petición responderá 401.
  void invalidarTokenParaPruebas() => _api.invalidarTokenParaPruebas();
}
