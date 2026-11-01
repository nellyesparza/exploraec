import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:exploraec/controllers/auth_controller.dart';
import 'package:exploraec/controllers/gastos_controller.dart';
import 'package:exploraec/models/resumen_gastos.dart';
import 'package:exploraec/screens/assistant_screen.dart';
import 'package:exploraec/services/ai_assistant_service.dart';
import 'package:exploraec/services/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

/// Backend de gastos falso (el contrato real, en memoria).
class _Backend implements HttpClientAdapter {
  /// Cada prueba recibe un usuario distinto: así cada una abre su propia caja de
  /// Hive (`gastos_<id>`) y no hay que cerrar ni borrar nada entre pruebas.
  static var _usuarios = 0;
  final idUsuario = ++_usuarios;
  final gastos = <Map<String, dynamic>>[];
  var _id = 1;

  ResponseBody _json(Object? cuerpo, int codigo, [Map<String, List<String>> h = const {}]) =>
      ResponseBody.fromString(cuerpo == null ? '' : jsonEncode(cuerpo), codigo,
          headers: {Headers.contentTypeHeader: ['application/json'], ...h});

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? cuerpo, Future<void>? cancelar) async {
    final texto = cuerpo == null ? '' : utf8.decode((await cuerpo.toList()).expand((x) => x).toList());
    final ruta = o.path;
    if (ruta == '/usuarios/token') return _json({'access_token': 'tok-a@b.com', 'token_type': 'bearer'}, 200);
    if (ruta == '/usuarios/me') return _json({'id': idUsuario, 'email': 'a@b.com'}, 200);
    if (ruta == '/gastos/categorias') {
      return _json({'categorias': ['comida', 'transporte', 'entretenimiento', 'otros'], 'limite_por_categoria': 500.0}, 200);
    }
    if (ruta == '/gastos/resumen') {
      final filas = ['comida', 'transporte', 'entretenimiento', 'otros'].map((c) {
        final propios = gastos.where((g) => g['categoria'] == c);
        final total = propios.fold<double>(0, (s, g) => s + (g['monto'] as num));
        return {'categoria': c, 'total': total, 'cantidad': propios.length, 'disponible': 500 - total};
      }).toList();
      return _json({'categorias': filas, 'total_general': filas.fold<double>(0, (s, f) => s + (f['total'] as num))}, 200);
    }
    if (ruta == '/gastos/' && o.method == 'GET') return _json(gastos, 200, {'x-total-count': ['${gastos.length}']});
    if (ruta == '/gastos/' && o.method == 'POST') {
      final nuevo = {'id': _id++, 'fecha': '2026-10-08', ...jsonDecode(texto) as Map<String, dynamic>};
      gastos.add(nuevo);
      return _json(nuevo, 201);
    }
    return _json({'detail': 'ruta no prevista en la prueba: $ruta'}, 404);
  }

  @override
  void close({bool force = false}) {}
}

/// Proxy del asistente falso: guarda lo que recibió para comprobar qué viaja.
class _Proxy implements HttpClientAdapter {
  RequestOptions? ultima;
  Map<String, dynamic>? cuerpo;
  Map<String, dynamic> respuesta = {'respuesta': 'Gastas más en comida.'};
  int codigo = 200;
  bool sinRed = false;

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? datos, Future<void>? cancelar) async {
    if (sinRed) throw DioException.connectionError(requestOptions: o, reason: 'proxy apagado');
    ultima = o;
    final texto = datos == null ? '' : utf8.decode((await datos.toList()).expand((x) => x).toList());
    cuerpo = jsonDecode(texto) as Map<String, dynamic>;
    return ResponseBody.fromString(jsonEncode(respuesta), codigo,
        headers: {Headers.contentTypeHeader: ['application/json']});
  }

  @override
  void close({bool force = false}) {}
}

const _resumen = ResumenGastos(
  categorias: [ResumenCategoria(categoria: 'comida', total: 20, cantidad: 2, disponible: 480)],
  totalGeneral: 20,
);

void main() {
  setUpAll(() => Hive.init(Directory.systemTemp.createTempSync('hive_s09').path));

  late _Backend backend;
  late _Proxy proxy;

  /// Monta la app con servidores falsos y la sesión ya iniciada.
  Future<void> montar() async {
    Get.reset();
    Get.testMode = true;
    FlutterSecureStorage.setMockInitialValues({});
    backend = _Backend();
    proxy = _Proxy();
    final api = Get.put(ApiClient(dio: Dio(BaseOptions(baseUrl: 'http://backend'))..httpClientAdapter = backend));
    Get.put(AiAssistantService(api: api, dio: Dio(BaseOptions(baseUrl: 'http://proxy'))..httpClientAdapter = proxy));
    final auth = Get.put(AuthController());
    await auth.iniciarSesion('a@b.com', 'clave-1234');
    final gastos = Get.put(GastosController());
    for (var i = 0; i < 200 && gastos.categorias.isEmpty; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  // ---- Servicio y modelo: ya vienen resueltos, deben pasar desde el principio ----

  test('El resumen viaja con los nombres del contrato y solo con totales por categoría', () {
    final json = _resumen.toJson();
    expect(json.keys, containsAll(['categorias', 'total_general']));
    expect((json['categorias'] as List).single.keys, containsAll(['categoria', 'total', 'cantidad', 'disponible']));
  });

  test('El servicio envía consulta y resumen (nada más) y el token solo en la cabecera', () async {
    await montar();
    Get.find<ApiClient>().token = 'tok-secreto';
    final servicio = Get.find<AiAssistantService>();
    final r = await servicio.preguntar('¿en qué categoría gasto más?', _resumen);
    expect(r.respuesta, 'Gastas más en comida.');
    expect(proxy.cuerpo!.keys.toSet(), {'consulta', 'resumen'});
    expect(jsonEncode(proxy.cuerpo), isNot(contains('tok-secreto')));
    expect(proxy.ultima!.headers['Authorization'], 'Bearer tok-secreto');
  });

  test('Una acción válida se lee; una incompleta se descarta', () async {
    await montar();
    final servicio = Get.find<AiAssistantService>();
    proxy.respuesta = {
      'respuesta': 'ok',
      'accion': {'tipo': 'registrar_gasto', 'descripcion': 'Almuerzo', 'monto': 6.5, 'categoria': 'comida'},
    };
    expect((await servicio.preguntar('x', _resumen)).accion!.monto, 6.5);
    proxy.respuesta = {'respuesta': 'ok', 'accion': {'tipo': 'borrar_todo', 'descripcion': 'x', 'monto': 1, 'categoria': 'comida'}};
    expect((await servicio.preguntar('x', _resumen)).accion, isNull);
  });

  test('Proxy apagado: mensaje claro, no una traza técnica', () async {
    await montar();
    proxy.sinRed = true;
    await expectLater(
      Get.find<AiAssistantService>().preguntar('x', _resumen),
      throwsA(predicate((e) => e.toString().contains('No se pudo conectar con el asistente'))),
    );
  });

  // ---- Pantalla: cada prueba la hace pasar un paso de la práctica ----

  Future<void> esperarRed(WidgetTester tester) async {
    // Alterna tiempo real (para que terminen las «peticiones» falsas y el disco)
    // con avance del reloj de la prueba (para los temporizadores de dio).
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 40)));
      await tester.pump(const Duration(milliseconds: 40));
    }
  }

  Future<void> abrirAsistente(WidgetTester tester) async {
    await tester.runAsync(montar);
    await tester.pumpWidget(const GetMaterialApp(home: AssistantScreen()));
    await tester.pump();
  }

  testWidgets('Paso 4 — preguntar muestra la respuesta del proxy', (tester) async {
    await abrirAsistente(tester);
    await tester.enterText(find.byType(TextField), '¿en qué categoría gasto más?');
    await tester.tap(find.text('Preguntar'));
    await esperarRed(tester);
    expect(find.text('Gastas más en comida.'), findsOneWidget);
    expect(proxy.cuerpo!['consulta'], '¿en qué categoría gasto más?');
  });

  testWidgets('Paso 5 — una acción propuesta pide confirmación y, al aceptar, crea el gasto', (tester) async {
    await abrirAsistente(tester);
    proxy.respuesta = {
      'respuesta': 'Puedo registrarlo.',
      'accion': {'tipo': 'registrar_gasto', 'descripcion': 'Almuerzo', 'monto': 6.5, 'categoria': 'comida'},
    };
    await tester.enterText(find.byType(TextField), 'registra un almuerzo de 6.50 en comida');
    await tester.tap(find.text('Preguntar'));
    await esperarRed(tester);
    expect(find.text('Confirmar acción'), findsOneWidget);
    expect(backend.gastos, isEmpty);
    await tester.tap(find.text('Registrar'));
    await esperarRed(tester);
    expect(backend.gastos.single['descripcion'], 'Almuerzo');
    expect(find.textContaining('Listo: registré'), findsOneWidget);
  });

  testWidgets('Paso 5 — cancelar la acción no crea ningún gasto', (tester) async {
    await abrirAsistente(tester);
    proxy.respuesta = {
      'respuesta': 'Puedo registrarlo.',
      'accion': {'tipo': 'registrar_gasto', 'descripcion': 'Almuerzo', 'monto': 6.5, 'categoria': 'comida'},
    };
    await tester.enterText(find.byType(TextField), 'registra un almuerzo de 6.50 en comida');
    await tester.tap(find.text('Preguntar'));
    await esperarRed(tester);
    await tester.tap(find.text('Cancelar'));
    await esperarRed(tester);
    expect(backend.gastos, isEmpty);
  });
}
