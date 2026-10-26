import 'package:dio/dio.dart';

import '../config/api_config.dart';
import 'api_exception.dart';

// Se reexportan para que quien use `ApiClient` tenga a mano `ApiException` y las
// opciones de `dio` para formularios (`Options`, `Headers`) sin más imports.
export 'package:dio/dio.dart' show Headers, Options;
export 'api_exception.dart';

/// Cliente HTTP único de la app — Sesión 8. Reemplaza al paquete `http` de
/// las Sesiones 6-7: una sola instancia de `dio` con la dirección del
/// backend, un tiempo máximo de 15 segundos y dos interceptores (código que
/// se ejecuta en TODAS las peticiones, sin repetirlo en cada pantalla).
class ApiClient {
  ApiClient({Dio? dio})
      : dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            )) {
    // Por qué: sin este interceptor habría que añadir la cabecera
    // `Authorization: Bearer <token>` a mano en cada llamada. Aquí se añade
    // sola a toda petición cuando hay un token guardado.
    // TODO(sesion-08) Paso 2: descomenta las 7 líneas de abajo (interceptor del token).
    this.dio.interceptors.add(InterceptorsWrapper(
      onRequest: (opciones, siguiente) {
        final t = token;
        if (t != null) opciones.headers['Authorization'] = 'Bearer $t';
        siguiente.next(opciones);
      },
    ));

    // Por qué: cuando el token caduca (30 minutos) cualquier pantalla recibe
    // un 401. En vez de manejarlo en cada una, este interceptor avisa en un
    // solo lugar. El login se excluye: ahí un 401 solo significa «contraseña
    // incorrecta».
    // TODO(sesion-08) Paso 7: descomenta las 9 líneas de abajo (interceptor del 401).
    this.dio.interceptors.add(InterceptorsWrapper(
      onError: (error, siguiente) {
        final esLogin = error.requestOptions.path == '/usuarios/token';
        if (error.response?.statusCode == 401 && !esLogin) {
          alSesionCaducada?.call();
        }
        siguiente.next(error);
      },
    ));
  }

  final Dio dio;

  /// Token JWT de la sesión actual. Vive aquí solo mientras la app está
  /// abierta; el almacenamiento seguro lo guarda entre aperturas.
  String? token;

  /// Lo asigna `AuthController`: se llama cuando el servidor responde 401.
  void Function()? alSesionCaducada;

  Future<Response<dynamic>> get(String ruta, {Map<String, dynamic>? query}) =>
      _enviar(() => dio.get(ruta, queryParameters: query));

  Future<Response<dynamic>> post(String ruta,
          {Object? data, Options? options}) =>
      _enviar(() => dio.post(ruta, data: data, options: options));

  Future<Response<dynamic>> put(String ruta, {Object? data}) =>
      _enviar(() => dio.put(ruta, data: data));

  Future<Response<dynamic>> patch(String ruta, {Object? data}) =>
      _enviar(() => dio.patch(ruta, data: data));

  Future<Response<dynamic>> delete(String ruta) =>
      _enviar(() => dio.delete(ruta));

  /// Único lugar con try/catch: todo error de `dio` sale como `ApiException`.
  Future<Response<dynamic>> _enviar(
      Future<Response<dynamic>> Function() peticion) async {
    try {
      return await peticion();
    } on DioException catch (e) {
      throw ApiException.desde(e);
    }
  }
}
