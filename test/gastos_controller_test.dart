import 'dart:convert';
import 'dart:io';

import 'package:exploraec/controllers/gastos_controller.dart';
import 'package:exploraec/controllers/places_controller.dart' show EstadoCarga;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _json(Object body, int code, {Map<String, String> h = const {}}) =>
    http.Response(jsonEncode(body), code, headers: {'content-type': 'application/json', ...h});

/// Servidor falso: usuarios y gastos en memoria según el contrato real.
MockClient _servidor({
  List<Map<String, dynamic>> gastos = const [],
  bool registroDuplicado = false,
  bool sinRed = false,
  int? falloListar,
}) {
  return MockClient((req) async {
    if (sinRed) throw const SocketException('sin red');
    final ruta = req.url.path;
    if (ruta == '/usuarios/' && req.method == 'POST') {
      final b = jsonDecode(req.body) as Map;
      if ((b['password'] as String).length < 8) {
        return _json({'detail': [{'type': 'string_too_short', 'loc': ['body', 'password'], 'msg': 'String should have at least 8 characters'}]}, 422);
      }
      if (registroDuplicado) return _json({'detail': 'El email ya está registrado'}, 400);
      return _json({'id': 1, 'email': b['email']}, 201);
    }
    if (ruta == '/usuarios/token') {
      expect(req.headers['content-type'], contains('application/x-www-form-urlencoded'));
      expect(req.bodyFields['username'], isNotEmpty);
      return _json({'access_token': 'tok', 'token_type': 'bearer'}, 200);
    }
    if (ruta == '/usuarios/me') {
      return _json({'id': 1, 'email': 'a@b.com'}, 200);
    }
    if (ruta == '/gastos/') {
      if (falloListar != null) return _json({'detail': 'x'}, falloListar);
      expect(req.headers['authorization'], 'Bearer tok');
      return _json(gastos, 200, h: {'x-total-count': '${gastos.length}'});
    }
    return _json({'detail': 'no existe'}, 404);
  });
}

void main() {
  setUpAll(() => Hive.init(Directory.systemTemp.createTempSync('hive_gastos').path));
  setUp(() async {
    Get.testMode = true;
    await Hive.deleteFromDisk(); // cada prueba parte sin ninguna caja
  });

  Future<GastosController> entrar(MockClient c, {String pass = 'clave-1234'}) async {
    final g = GastosController();
    await http.runWithClient(() => g.entrar('a@b.com', pass), () => c);
    return g;
  }

  final dosGastos = [
    {'id': 1, 'descripcion': 'Almuerzo', 'monto': 6.5, 'categoria': 'comida', 'fecha': '2026-10-05'},
    {'id': 2, 'descripcion': 'Taxi', 'monto': 3, 'categoria': 'transporte', 'fecha': '2026-10-05'},
  ];

  test('usuario nuevo: registro -> login -> lista vacía', () async {
    final g = await entrar(_servidor());
    expect(g.sesionActiva.value, isTrue);
    expect(g.estado.value, EstadoCarga.exito);
    expect(g.gastos, isEmpty);
  });

  test('éxito: carga gastos y total (monto entero o decimal), sin banner', () async {
    final g = await entrar(_servidor(gastos: dosGastos));
    expect(g.gastos.length, 2);
    expect(g.totalEnServidor.value, 2);
    expect(g.gastos[1].monto, 3.0);
    expect(g.desdeCache.value, isFalse);
  });

  test('400 al registrar (correo existente) se ignora y sigue al login', () async {
    final g = await entrar(_servidor(registroDuplicado: true));
    expect(g.sesionActiva.value, isTrue);
  });

  test('422 al registrar: mensaje legible con el campo, sin sesión', () async {
    final g = await entrar(_servidor(), pass: 'abc');
    expect(g.sesionActiva.value, isFalse);
    expect(g.mensajeAuth.value, startsWith('Datos inválidos — password:'));
  });

  test('5xx sin nada en caché: error legible', () async {
    final g = await entrar(_servidor(falloListar: 503));
    expect(g.estado.value, EstadoCarga.error);
    expect(g.mensajeError.value, 'El servidor tuvo un problema. Inténtalo más tarde.');
  });

  // --- Pruebas de la Sesión 7: fallan hasta completar el Paso 2 / el Paso 5 ---

  test('Paso 2 — sin conexión con caché: muestra lo guardado y marca desdeCache', () async {
    final g = await entrar(_servidor(gastos: dosGastos));
    await http.runWithClient(() => g.cargarGastos(), () => _servidor(sinRed: true));
    expect(g.estado.value, EstadoCarga.exito);
    expect(g.desdeCache.value, isTrue);
    expect(g.gastos.length, 2);
    expect(g.ultimaSincronizacion, isNot('desconocida'));
  });

  test('Paso 2 — 5xx con caché: también cae a la caché', () async {
    final g = await entrar(_servidor(gastos: dosGastos));
    await http.runWithClient(() => g.cargarGastos(), () => _servidor(falloListar: 503));
    expect(g.desdeCache.value, isTrue);
    expect(g.gastos.length, 2);
  });

  test('Paso 2 — al volver el servidor, el banner desaparece', () async {
    final g = await entrar(_servidor(gastos: dosGastos));
    await http.runWithClient(() => g.cargarGastos(), () => _servidor(sinRed: true));
    await http.runWithClient(() => g.cargarGastos(), () => _servidor(gastos: dosGastos));
    expect(g.desdeCache.value, isFalse);
  });

  test('Paso 2 — un 401 NO usa la caché: vuelve al formulario', () async {
    final g = await entrar(_servidor(gastos: dosGastos));
    await http.runWithClient(() => g.cargarGastos(), () => _servidor(falloListar: 401));
    expect(g.sesionActiva.value, isFalse);
    expect(g.desdeCache.value, isFalse);
    expect(g.mensajeAuth.value, startsWith('Tu sesión caducó'));
  });

  test('Paso 5 — cerrar sesión borra la caja del usuario', () async {
    final g = await entrar(_servidor(gastos: dosGastos));
    expect(await Hive.boxExists('gastos_1'), isTrue);
    await g.salir();
    expect(await Hive.boxExists('gastos_1'), isFalse);
    expect(g.sesionActiva.value, isFalse);
  });
}
