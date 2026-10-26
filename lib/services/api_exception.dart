import 'dart:io';

import 'package:dio/dio.dart';

/// Error de red o HTTP ya traducido a un mensaje legible — Sesión 6. Desde la
/// Sesión 8 se construye a partir de un `DioException` con
/// `ApiException.desde(...)`. `statusCode` es null cuando el fallo no vino de
/// una respuesta HTTP (sin conexión, tiempo agotado).
class ApiException implements Exception {
  final String mensaje;
  final int? statusCode;
  ApiException(this.mensaje, {this.statusCode});

  /// Único lugar donde un error de `dio` se convierte en texto para el usuario.
  factory ApiException.desde(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
            'El servidor tardó demasiado en responder. Revisa tu conexión e inténtalo de nuevo.');
      case DioExceptionType.badResponse:
        return _desdeRespuesta(e.response!, e.requestOptions.path);
      default:
        if (e.type == DioExceptionType.connectionError || e.error is SocketException) {
          return ApiException(
              'No hay conexión con el servidor. Revisa tu red y que el backend esté encendido.');
        }
        return ApiException('No se pudo completar la petición. Inténtalo de nuevo.');
    }
  }

  static ApiException _desdeRespuesta(Response<dynamic> r, String ruta) {
    final codigo = r.statusCode ?? 0;
    final detail = r.data is Map ? (r.data as Map)['detail'] : null;
    if (codigo == 401) {
      // En el login un 401 significa «credenciales incorrectas»; en cualquier
      // otra ruta significa «el token ya no sirve».
      if (ruta == '/usuarios/token' && detail is String) {
        return ApiException(detail, statusCode: 401);
      }
      return ApiException('Tu sesión caducó, inicia sesión de nuevo.', statusCode: 401);
    }
    if (codigo >= 500) {
      return ApiException('El servidor tuvo un problema. Inténtalo más tarde.', statusCode: codigo);
    }
    // 400 / 403 / 404: `detail` es un texto en español. 422: `detail` es una LISTA.
    if (detail is String) return ApiException(detail, statusCode: codigo);
    if (detail is List) {
      final partes = detail.whereType<Map>().map((e) {
        final loc = e['loc'];
        final campo = loc is List && loc.isNotEmpty ? '${loc.last}' : 'dato';
        return '$campo: ${e['msg']}';
      });
      return ApiException('Datos inválidos — ${partes.join('; ')}', statusCode: codigo);
    }
    return ApiException('La petición no pudo completarse (código $codigo).', statusCode: codigo);
  }

  @override
  String toString() => mensaje;
}
