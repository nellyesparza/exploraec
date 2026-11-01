import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../models/resumen_gastos.dart';
import 'api_client.dart';

/// Dirección del proxy del asistente — Sesión 9. Se cambia al ejecutar con
/// `--dart-define=LLM_BACKEND_URL=...`. El valor por defecto es cómo el
/// emulador Android ve el `localhost` de tu computador. La app NO conoce
/// ninguna clave de IA: solo la dirección del proxy.
const String kAiBackendUrl = String.fromEnvironment(
  'LLM_BACKEND_URL',
  defaultValue: 'http://10.0.2.2:3000',
);

/// Acción que el asistente propone (por ahora, registrar un gasto). La app
/// NUNCA la ejecuta sola: pide confirmación a la persona primero.
class AccionPropuesta {
  final String tipo;
  final String descripcion;
  final double monto;
  final String categoria;

  const AccionPropuesta({
    required this.tipo,
    required this.descripcion,
    required this.monto,
    required this.categoria,
  });

  /// Devuelve null si la acción llega incompleta o con otro tipo: la respuesta
  /// de una IA se trata como un dato que hay que validar, no como código.
  static AccionPropuesta? desdeJson(Object? json) {
    if (json is! Map) return null;
    final tipo = json['tipo'];
    final descripcion = json['descripcion'];
    final monto = json['monto'];
    final categoria = json['categoria'];
    if (tipo != 'registrar_gasto' ||
        descripcion is! String ||
        descripcion.trim().isEmpty ||
        monto is! num ||
        monto <= 0 ||
        categoria is! String) {
      return null;
    }
    return AccionPropuesta(
      tipo: tipo as String,
      descripcion: descripcion.trim(),
      monto: monto.toDouble(),
      categoria: categoria,
    );
  }
}

class RespuestaIA {
  final String respuesta;
  final AccionPropuesta? accion;
  const RespuestaIA({required this.respuesta, this.accion});

  factory RespuestaIA.fromJson(Map<String, dynamic> json) => RespuestaIA(
        respuesta: (json['respuesta'] as String?) ?? 'El asistente no devolvió ninguna respuesta.',
        accion: AccionPropuesta.desdeJson(json['accion']),
      );
}

/// Error del asistente ya traducido a un mensaje legible.
class AsistenteException implements Exception {
  final String mensaje;
  AsistenteException(this.mensaje);
  @override
  String toString() => mensaje;
}

/// Habla con el proxy del asistente — Sesión 9. Mismo patrón asíncrono de la
/// Sesión 6 (timeout y errores traducidos), con una diferencia clave: aquí no
/// hay ninguna clave de IA. Solo viaja la consulta, el resumen por categoría y
/// el token de la sesión (en la cabecera, nunca en el cuerpo ni en los logs).
class AiAssistantService {
  AiAssistantService({ApiClient? api, Dio? dio})
      : _api = api ?? Get.find<ApiClient>(),
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: kAiBackendUrl,
              connectTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
            ));

  final ApiClient _api;
  final Dio _dio;

  Future<RespuestaIA> preguntar(String consulta, ResumenGastos resumen) async {
    final token = _api.token;
    try {
      final r = await _dio.post(
        '/asistente',
        data: {'consulta': consulta, 'resumen': resumen.toJson()},
        options: Options(headers: {if (token != null) 'Authorization': 'Bearer $token'}),
      );
      final json = r.data;
      if (json is! Map) {
        throw AsistenteException('La respuesta del asistente no tiene el formato esperado.');
      }
      return RespuestaIA.fromJson(Map<String, dynamic>.from(json));
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw AsistenteException('El asistente tardó demasiado en responder. Inténtalo de nuevo.');
        case DioExceptionType.badResponse:
          final detail = e.response?.data is Map ? (e.response!.data as Map)['detail'] : null;
          throw AsistenteException(detail is String
              ? detail
              : 'El asistente respondió con un error (código ${e.response?.statusCode}).');
        default:
          throw AsistenteException(
              'No se pudo conectar con el asistente. Revisa que el proxy esté encendido.');
      }
    }
  }
}
