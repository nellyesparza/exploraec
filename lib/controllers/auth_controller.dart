import 'package:get/get.dart';

import '../models/usuario.dart';
import '../services/api_client.dart';
import '../services/secure_token_storage.dart';
// Solo lo usa el bloque del Paso 8 (comentado hasta entonces).
// ignore: unused_import
import 'gastos_controller.dart';

/// Estado de la sesión de toda la app — Sesión 8 (mismo patrón de GetX de las
/// Sesiones 4-7: el controller guarda el estado y `Obx` reconstruye la
/// pantalla). `usuario` es null cuando no hay sesión.
class AuthController extends GetxController {
  AuthController({ApiClient? api, SecureTokenStorage? almacen})
      : _api = api ?? Get.find<ApiClient>(),
        _almacen = almacen ?? SecureTokenStorage();

  final ApiClient _api;
  final SecureTokenStorage _almacen;

  final Rxn<Usuario> usuario = Rxn<Usuario>();
  final RxBool cargando = false.obs;

  /// `true` mientras se comprueba el token guardado al abrir la app.
  final RxBool restaurando = false.obs;

  /// Error del último intento de registro o inicio de sesión.
  final RxString mensajeError = ''.obs;

  /// Aviso que se muestra donde pide iniciar sesión (por ejemplo, «caducó»).
  final RxString avisoSesion = ''.obs;

  bool get estaAutenticado => usuario.value != null;

  @override
  void onInit() {
    super.onInit();
    _api.alSesionCaducada = sesionCaducada;
    restaurarSesion();
  }

  /// POST /usuarios/ con JSON y, si sale bien (201), inicia sesión.
  /// Correo repetido → 400 con el motivo en `detail`.
  Future<void> registrar(String email, String password) async {
    // Por qué: crear la cuenta y entrar son dos peticiones seguidas; `await`
    // permite escribirlas en orden. Un error del servidor se muestra tal cual.
    // TODO(sesion-08) Paso 3: descomenta las 10 líneas de abajo (registrar).
    // cargando.value = true;
    // mensajeError.value = '';
    // try {
    //   await _api.post('/usuarios/', data: {'email': email, 'password': password});
    //   await iniciarSesion(email, password);
    // } on ApiException catch (e) {
    //   mensajeError.value = e.mensaje;
    // } finally {
    //   cargando.value = false;
    // }
  }

  /// POST /usuarios/token — OJO: `application/x-www-form-urlencoded`, no JSON.
  /// El campo se llama `username` pero lleva el correo.
  Future<void> iniciarSesion(String email, String password) async {
    // Por qué: el endpoint de login sigue el estándar OAuth2 y exige un
    // formulario, no JSON; mandar JSON devuelve 422. El token recibido se
    // guarda en memoria (para el interceptor) y en el almacenamiento seguro.
    // TODO(sesion-08) Paso 2: descomenta las 18 líneas de abajo (iniciar sesión).
    // cargando.value = true;
    // mensajeError.value = '';
    // try {
    //   final r = await _api.post(
    //     '/usuarios/token',
    //     data: {'username': email, 'password': password},
    //     options: Options(contentType: Headers.formUrlEncodedContentType),
    //   );
    //   final token = (r.data as Map)['access_token'] as String;
    //   _api.token = token;
    //   await _almacen.guardar(token);
    //   await cargarUsuario();
    //   avisoSesion.value = '';
    // } on ApiException catch (e) {
    //   mensajeError.value = e.mensaje;
    // } finally {
    //   cargando.value = false;
    // }
  }

  /// Al abrir la app: si hay un token guardado, comprueba con el servidor que
  /// siga siendo válido (GET /usuarios/me) y deja la sesión abierta.
  Future<void> restaurarSesion() async {
    // Por qué: sin esto la sesión se perdería en cada arranque. Un 401 quiere
    // decir que el token caducó: se borra y se pide iniciar sesión. Otro error
    // (sin conexión) no borra nada: el token puede seguir siendo válido.
    // TODO(sesion-08) Paso 4: descomenta las 16 líneas de abajo (restaurar sesión).
    // restaurando.value = true;
    // try {
    //   final guardado = await _almacen.leer();
    //   if (guardado == null) return;
    //   _api.token = guardado;
    //   await cargarUsuario();
    // } on ApiException catch (e) {
    //   if (e.statusCode == 401) {
    //     await cerrarSesion();
    //     avisoSesion.value = 'Tu sesión caducó, inicia sesión de nuevo.';
    //   } else {
    //     avisoSesion.value = e.mensaje;
    //   }
    // } finally {
    //   restaurando.value = false;
    // }
  }

  /// Lo llama el interceptor cuando el servidor responde 401 (token vencido).
  Future<void> sesionCaducada() async {
    await cerrarSesion();
    avisoSesion.value = 'Tu sesión caducó, inicia sesión de nuevo.';
    // Si había una pantalla encima (por ejemplo, el formulario), se vuelve a la base.
    if (Get.key.currentState != null) Get.until((ruta) => ruta.isFirst);
  }

  /// Borra el token (seguro y en memoria) y deja la sesión cerrada.
  Future<void> cerrarSesion() async {
    // Por qué: el token solo es una parte de lo que identifica a la persona.
    // Su copia de gastos (la caja de Hive de la Sesión 7) y la lista en
    // pantalla también deben borrarse, o la siguiente persona que use este
    // teléfono las vería.
    // TODO(sesion-08) Paso 8: descomenta la línea de abajo (limpiar los gastos).
    // if (Get.isRegistered<GastosController>()) await Get.find<GastosController>().limpiar();
    await _almacen.borrar();
    _api.token = null;
    usuario.value = null;
  }

  /// PUT /usuarios/me/password — responde 204 (sin cuerpo). Si sale bien, cierra
  /// la sesión para entrar con la contraseña nueva.
  Future<void> cambiarPassword(String actual, String nueva) async {
    // Por qué: un 204 no trae cuerpo, así que no hay nada que leer de la
    // respuesta. Con la contraseña actual equivocada el servidor responde con
    // un error y su mensaje se muestra tal cual.
    // TODO(sesion-08) OPCIONAL Paso 9: descomenta las 10 líneas de abajo (cambiar contraseña).
    // cargando.value = true;
    // mensajeError.value = '';
    // try {
    //   await _api.put('/usuarios/me/password', data: {'password_actual': actual, 'password_nueva': nueva});
    //   await cerrarSesion();
    // } on ApiException catch (e) {
    //   mensajeError.value = e.mensaje;
    // } finally {
    //   cargando.value = false;
    // }
  }

  /// GET /usuarios/me → deja el usuario de la sesión en `usuario`.
  Future<void> cargarUsuario() async {
    final r = await _api.get('/usuarios/me');
    usuario.value = Usuario.fromJson(Map<String, dynamic>.from(r.data as Map));
  }

  /// Solo práctica (Paso 7): la siguiente petición responderá 401.
  void invalidarTokenParaPruebas() => _api.token = 'token-invalido';
}
