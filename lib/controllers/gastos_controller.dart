import 'package:get/get.dart';

import '../models/gasto.dart';
import '../repositories/gastos_repository.dart';
import '../services/api_client.dart';
import '../services/gastos_api_service.dart';
import 'auth_controller.dart';
import 'places_controller.dart' show EstadoCarga;

/// Estado de la sección Gastos (patrón de la Sesión 4: el controller guarda
/// el estado y `Obx` reconstruye la pantalla). Desde la Sesión 7 los gastos
/// pasan por `GastosRepository` (servidor primero, caché de Hive como
/// respaldo). Desde la Sesión 8 la sesión la maneja `AuthController` y aquí
/// se agrega el CRUD completo.
class GastosController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();
  late final GastosApiService _api = GastosApiService(Get.find<ApiClient>());
  late final GastosRepository _repository = GastosRepository(_api);

  final RxList<Gasto> gastos = <Gasto>[].obs;
  final Rx<EstadoCarga> estado = EstadoCarga.exito.obs;
  final RxString mensajeError = ''.obs;
  final RxInt totalEnServidor = 0.obs;

  /// Categorías que define el backend (`GET /gastos/categorias`).
  final RxList<String> categorias = <String>[].obs;

  /// `true` solo cuando la última carga exitosa vino de la caché local (el
  /// servidor no respondió): la UI lo usa para avisar «datos guardados».
  final RxBool desdeCache = false.obs;
  String get ultimaSincronizacion => _repository.ultimaSincronizacion;

  @override
  void onInit() {
    super.onInit();
    // Cuando `AuthController` deja un usuario (login, registro o sesión
    // restaurada), se cargan sus datos. Si ya hay uno, se cargan de una vez.
    ever(_auth.usuario, (u) {
      if (u != null) iniciar();
    });
    if (_auth.estaAutenticado) iniciar();
  }

  /// Abre la caja del usuario, pide las categorías y carga sus gastos.
  Future<void> iniciar() async {
    estado.value = EstadoCarga.cargando;
    try {
      await _repository.abrirParaUsuario();
      await cargarCategorias();
    } on ApiException catch (e) {
      mensajeError.value = e.mensaje;
      estado.value = EstadoCarga.error;
      return;
    }
    await cargarGastos();
  }

  Future<void> cargarGastos() async {
    estado.value = EstadoCarga.cargando;
    try {
      await _refrescar();
      estado.value = EstadoCarga.exito;
    } on ApiException catch (e) {
      mensajeError.value = e.mensaje;
      estado.value = EstadoCarga.error;
    }
  }

  /// Vuelve a pedir la lista al repositorio sin pasar por «cargando»: se usa
  /// después de crear, editar o eliminar para que la pantalla no parpadee.
  Future<void> _refrescar() async {
    final (lista, cache) = await _repository.obtenerGastos();
    gastos.value = lista;
    totalEnServidor.value = lista.length;
    desdeCache.value = cache;
  }

  Future<void> cargarCategorias() async {
    // Por qué: las categorías (y el límite de 500) las decide el servidor; la
    // app solo las muestra. Si mañana el backend agrega una, aparece sola.
    // TODO(sesion-08) Paso 5: descomenta las 2 líneas de abajo (categorías).
    // final r = await _api.listarCategorias();
    // categorias.assignAll(r.categorias);
  }

  /// Crea un gasto. Si el servidor lo rechaza (por ejemplo, el límite de 500),
  /// lanza `ApiException` con el mensaje para que el formulario lo muestre.
  Future<void> crear(String descripcion, double monto, String categoria) async {
    // Por qué: se manda el gasto al servidor y la pantalla se actualiza con lo
    // que el servidor guardó realmente (no se supone que salió bien).
    // TODO(sesion-08) Paso 5: descomenta las 2 líneas de abajo (crear).
    // await _api.crear({'descripcion': descripcion, 'monto': monto, 'categoria': categoria});
    // await _refrescar();
  }

  /// Edita un gasto enviando SOLO los campos que cambiaron.
  Future<void> actualizar(int id, Map<String, dynamic> cambios) async {
    // Por qué: PATCH modifica solo lo que se envía. Si el gasto ya no existe
    // (404), se refresca la lista para que desaparezca de la pantalla.
    // TODO(sesion-08) Paso 6: descomenta las 7 líneas de abajo (editar).
    // try {
    //   await _api.actualizar(id, cambios);
    // } on ApiException catch (e) {
    //   if (e.statusCode == 404) await _refrescar();
    //   rethrow;
    // }
    // await _refrescar();
  }

  Future<void> eliminar(int id) async {
    // Por qué: mismo patrón que editar. El servidor responde 204 (sin cuerpo)
    // y la lista se vuelve a pedir, así la caché de Hive también se actualiza.
    // TODO(sesion-08) Paso 6: descomenta las 7 líneas de abajo (eliminar).
    // try {
    //   await _api.eliminar(id);
    // } on ApiException catch (e) {
    //   if (e.statusCode == 404) await _refrescar();
    //   rethrow;
    // }
    // await _refrescar();
  }

  /// Borra todo lo de la persona que cierra sesión: la lista en pantalla y su
  /// caja de Hive (`GastosRepository.vaciar`, Sesión 7).
  Future<void> limpiar() async {
    await _repository.vaciar();
    gastos.clear();
    categorias.clear();
    totalEnServidor.value = 0;
    desdeCache.value = false;
    mensajeError.value = '';
    estado.value = EstadoCarga.exito;
  }
}
