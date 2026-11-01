// Solo los usan las pruebas comentadas del Paso 3.
// ignore_for_file: unused_import, unused_element
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show PlatformDispatcher;

import 'package:dio/dio.dart';
import 'package:exploraec/controllers/auth_controller.dart';
import 'package:exploraec/screens/pantalla_con_fallo.dart';
import 'package:exploraec/screens/register_screen.dart';
import 'package:exploraec/services/api_client.dart';
import 'package:exploraec/utils/reporte_errores.dart';
import 'package:exploraec/widgets/error_pantalla_view.dart';
import 'package:exploraec/widgets/sin_sesion_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Servidor falso que solo cuenta cuántas peticiones recibe: sirve para
/// comprobar que la app NO llama al servidor cuando el formulario es inválido.
class _Servidor implements HttpClientAdapter {
  final peticiones = <String>[];

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? cuerpo, Future<void>? cancelar) async {
    peticiones.add('${o.method} ${o.path}');
    return ResponseBody.fromString(jsonEncode({'detail': 'no previsto en la prueba'}), 404,
        headers: {Headers.contentTypeHeader: ['application/json']});
  }

  @override
  void close({bool force = false}) {}
}

/// Monta ApiClient y AuthController con el servidor falso, sin sesión guardada.
({_Servidor servidor, AuthController auth}) _montar() {
  Get.reset();
  Get.testMode = true;
  FlutterSecureStorage.setMockInitialValues({});
  final servidor = _Servidor();
  Get.put(ApiClient(dio: Dio(BaseOptions(baseUrl: 'http://prueba'))..httpClientAdapter = servidor));
  return (servidor: servidor, auth: Get.put(AuthController()));
}

/// `ReporteErrores.instalar()` cambia manejadores globales: se restauran al
/// terminar para no afectar a las demás pruebas.
void _restaurarManejadoresAlTerminar() {
  final onError = FlutterError.onError;
  final builder = ErrorWidget.builder;
  final dispatcher = PlatformDispatcher.instance.onError;
  addTearDown(() {
    FlutterError.onError = onError;
    ErrorWidget.builder = builder;
    PlatformDispatcher.instance.onError = dispatcher;
  });
}

void main() {
  // ---- Ya vienen resueltas: pasan desde el principio ----

  test('limpiar() quita los tokens y las cabeceras Bearer de un mensaje', () {
    const jwt = 'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhQGIuY29tIn0.firma123';
    final limpio = ReporteErrores.limpiar('fallo con Authorization: Bearer $jwt y token $jwt');
    expect(limpio, isNot(contains('eyJ')));
    expect(limpio, contains('Bearer ***'));
  });

  test('registrar() guarda el error limpio y conserva solo los 20 más recientes', () {
    ReporteErrores.recientes.clear();
    for (var i = 0; i < 25; i++) {
      ReporteErrores.registrar(StateError('fallo $i Bearer abc.def.ghi'), StackTrace.empty);
    }
    expect(ReporteErrores.recientes.length, 20);
    expect(ReporteErrores.recientes.last, contains('fallo 24'));
    expect(ReporteErrores.recientes.join(), isNot(contains('abc.def.ghi')));
  });

  // ---- Paso 2: pasa cuando descomentas el bloque de `ReporteErrores.instalar()` ----

  test('Paso 2 — instalar() reemplaza la pantalla roja por la vista amistosa y absorbe los errores asíncronos', () {
    _restaurarManejadoresAlTerminar();
    ReporteErrores.instalar();
    expect(ErrorWidget.builder(FlutterErrorDetails(exception: StateError('x'))), isA<ErrorPantallaView>());
    expect(PlatformDispatcher.instance.onError!(StateError('x'), StackTrace.empty), isTrue);
  });

  // ---- Paso 3: pruebas de widgets (están comentadas: las descomentas tú) ----

  // Por qué: una prueba de widget arma una pantalla, escribe y toca como lo haría
  // una persona, y comprueba lo que se ve. Estas tres no necesitan el backend ni
  // el emulador: usan un servidor falso.
  // TODO(sesion-10) Paso 3: descomenta las 27 líneas de abajo (pruebas de widgets).
  // testWidgets('Paso 3 — sin sesión se ve el motivo y el botón para iniciar sesión', (tester) async {
  //   final montaje = _montar();
  //   montaje.auth.avisoSesion.value = 'Tu sesión caducó, inicia sesión de nuevo.';
  //   await tester.pumpWidget(const GetMaterialApp(home: SinSesionView()));
  //   await tester.pump(const Duration(milliseconds: 50));
  //   expect(find.text('Tu sesión caducó, inicia sesión de nuevo.'), findsOneWidget);
  //   expect(find.text('Iniciar sesión'), findsOneWidget);
  // });
  //
  // testWidgets('Paso 3 — registrar con una contraseña corta se rechaza sin llamar al servidor', (tester) async {
  //   final montaje = _montar();
  //   await tester.pumpWidget(const GetMaterialApp(home: RegisterScreen()));
  //   await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
  //   await tester.enterText(find.byType(TextFormField).at(1), 'abc');
  //   await tester.tap(find.widgetWithText(FilledButton, 'Crear cuenta'));
  //   await tester.pump();
  //   expect(find.text('La contraseña debe tener entre 8 y 72 caracteres'), findsOneWidget);
  //   expect(montaje.servidor.peticiones, isEmpty);
  // });
  //
  // testWidgets('Paso 3 — una pantalla que falla muestra la vista amistosa, no la roja', (tester) async {
  //   _restaurarManejadoresAlTerminar();
  //   ReporteErrores.instalar();
  //   await tester.pumpWidget(const MaterialApp(home: PantallaConFallo()));
  //   expect(find.byType(ErrorPantallaView), findsOneWidget);
  //   expect(find.text('Esta pantalla tuvo un problema'), findsOneWidget);
  // });
}
