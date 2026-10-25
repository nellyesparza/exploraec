import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/gasto.dart';
import 'api_exception.dart';

/// Primer consumo real de una API (Sesión 6). Paquete `http`; en la Sesión 8
/// se reemplaza por `dio` con interceptores.
class GastosApiService {
  /// Token JWT solo en memoria (S6-S7). Nunca a disco ni a los logs;
  /// `flutter_secure_storage` llega en la Sesión 8.
  String? _token;

  bool get tieneToken => _token != null;

  void cerrarSesion() => _token = null;

  /// Solo práctica (Paso 8): provoca un 401 real en la siguiente petición.
  void invalidarTokenParaPruebas() => _token = 'token-invalido';

  /// POST /usuarios/ — cuerpo JSON. 400 si el correo ya existe.
  Future<void> registrar(String email, String password) async {
    await _enviar(() => http.post(
          Uri.parse('${ApiConfig.baseUrl}/usuarios/'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        ));
  }

  /// POST /usuarios/token — OJO: `application/x-www-form-urlencoded`, no JSON.
  /// El campo se llama `username` pero lleva el correo.
  Future<void> login(String email, String password) async {
    final respuesta = await _enviar(() => http.post(
          Uri.parse('${ApiConfig.baseUrl}/usuarios/token'),
          // Un Map como body => `http` usa form-urlencoded por ti.
          body: {'username': email, 'password': password},
        ));
    final json = jsonDecode(utf8.decode(respuesta.bodyBytes));
    final token = json is Map ? json['access_token'] : null;
    if (token is! String) {
      throw ApiException('Respuesta inesperada del servidor al iniciar sesión.');
    }
    _token = token;
  }

  /// GET /usuarios/me — `{id, email}`. La Sesión 7 usa el `id` para dar a la
  /// caja de Hive de cada usuario su propio nombre (`gastos_<id>`).
  Future<int> obtenerIdUsuario() async {
    final respuesta = await _get('/usuarios/me');
    final json = jsonDecode(utf8.decode(respuesta.bodyBytes));
    final id = json is Map ? json['id'] : null;
    if (id is! int) {
      throw ApiException('Respuesta inesperada del servidor al leer tu perfil.');
    }
    return id;
  }

  /// GET /gastos/?skip=&limit= (con barra final: sin ella el servidor responde 307; `http` sigue la redirección en GET, pero no en POST) — el total viene en la cabecera X-Total-Count.
  Future<({List<Gasto> gastos, int total})> listarGastos({
    int skip = 0,
    int limit = 20,
  }) async {
    final respuesta = await _get('/gastos/', {'skip': '$skip', 'limit': '$limit'});
    final json = jsonDecode(utf8.decode(respuesta.bodyBytes));
    if (json is! List) {
      throw ApiException('Respuesta inesperada del servidor al listar gastos.');
    }
    final gastos = json
        .whereType<Map<String, dynamic>>()
        .map(Gasto.fromJson)
        .toList();
    final total = int.tryParse(respuesta.headers['x-total-count'] ?? '') ?? gastos.length;
    return (gastos: gastos, total: total);
  }

  /// GET autenticado reutilizable (las sesiones siguientes lo amplían).
  Future<http.Response> _get(String ruta, [Map<String, String>? query]) {
    final token = _token;
    if (token == null) {
      throw ApiException('Inicia sesión para ver tus gastos.', statusCode: 401);
    }
    final uri = Uri.parse('${ApiConfig.baseUrl}$ruta').replace(queryParameters: query);
    return _enviar(() => http.get(uri, headers: {'Authorization': 'Bearer $token'}));
  }

  /// Único lugar con try/catch y timeout: toda petición pasa por aquí.
  Future<http.Response> _enviar(Future<http.Response> Function() peticion) async {
    try {
      final respuesta = await peticion().timeout(const Duration(seconds: 15));
      if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
        return respuesta;
      }
      throw _errorHttp(respuesta);
    } on SocketException {
      throw ApiException(
          'No hay conexión con el servidor. Revisa tu red y que el backend esté encendido.');
    } on http.ClientException {
      throw ApiException(
          'No hay conexión con el servidor. Revisa tu red y que el backend esté encendido.');
    } on TimeoutException {
      throw ApiException(
          'El servidor tardó demasiado en responder. Revisa tu conexión e inténtalo de nuevo.');
    }
  }

  ApiException _errorHttp(http.Response r) {
    final codigo = r.statusCode;
    if (codigo == 401) {
      return ApiException(
          'Tu sesión caducó o las credenciales no son válidas. Inicia sesión de nuevo.',
          statusCode: 401);
    }
    if (codigo >= 500) {
      return ApiException('El servidor tuvo un problema. Inténtalo más tarde.',
          statusCode: codigo);
    }
    // 400 / 403 / 404: `detail` es un texto en español. 422: `detail` es una LISTA.
    return ApiException(_leerDetail(r, codigo), statusCode: codigo);
  }

  String _leerDetail(http.Response r, int codigo) {
    try {
      final json = jsonDecode(utf8.decode(r.bodyBytes));
      final detail = json is Map ? json['detail'] : null;
      if (detail is String) return detail;
      if (detail is List) {
        final partes = detail.whereType<Map>().map((e) {
          final loc = e['loc'];
          final campo = loc is List && loc.isNotEmpty ? '${loc.last}' : 'dato';
          return '$campo: ${e['msg']}';
        });
        return 'Datos inválidos — ${partes.join('; ')}';
      }
    } on FormatException {
      // cuerpo que no es JSON: cae al mensaje genérico
    }
    return 'La petición no pudo completarse (código $codigo).';
  }
}
