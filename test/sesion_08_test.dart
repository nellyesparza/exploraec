import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:exploraec/controllers/auth_controller.dart';
import 'package:exploraec/controllers/gastos_controller.dart';
import 'package:exploraec/services/api_client.dart';
import 'package:exploraec/services/secure_token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

/// Servidor falso que imita el contrato real del backend de gastos: usuarios,
/// token, gastos con límite de 500 por categoría y errores con `detail`.
/// No necesita el backend ni el emulador. Cada prueba lleva en el nombre el
/// paso de la práctica que la hace pasar.
class _Servidor implements HttpClientAdapter {
  final usuarios = <String, String>{'a@b.com': 'clave-1234'};
  final gastos = <Map<String, dynamic>>[];
  final peticiones = <RequestOptions>[];
  var _siguienteId = 1;
  bool tokenVencido = false;

  ResponseBody _json(Object? cuerpo, int codigo, [Map<String, List<String>> h = const {}]) =>
      ResponseBody.fromString(cuerpo == null ? '' : jsonEncode(cuerpo), codigo,
          headers: {Headers.contentTypeHeader: ['application/json'], ...h});

  @override
  Future<ResponseBody> fetch(RequestOptions o, Stream<Uint8List>? cuerpo, Future<void>? cancelar) async {
    peticiones.add(o);
    final texto = cuerpo == null ? '' : utf8.decode((await cuerpo.toList()).expand((x) => x).toList());
    final ruta = o.path;
    if (ruta == '/usuarios/' && o.method == 'POST') {
      final b = jsonDecode(texto) as Map;
      if (usuarios.containsKey(b['email'])) {
        return _json({'detail': 'El email ${b['email']} ya está registrado'}, 400);
      }
      usuarios[b['email'] as String] = b['password'] as String;
      return _json({'id': usuarios.length, 'email': b['email']}, 201);
    }
    if (ruta == '/usuarios/token') {
      final tipo = o.headers[Headers.contentTypeHeader].toString();
      if (!tipo.contains('application/x-www-form-urlencoded')) {
        return _json({'detail': [{'type': 'missing', 'loc': ['body', 'username'], 'msg': 'Field required'}]}, 422);
      }
      final campos = Uri.splitQueryString(texto);
      if (usuarios[campos['username']] != campos['password']) {
        return _json({'detail': 'Email o contraseña incorrectos'}, 401);
      }
      return _json({'access_token': 'tok-${campos['username']}', 'token_type': 'bearer'}, 200);
    }
    // Desde aquí todo exige token válido.
    final auth = o.headers['Authorization'];
    if (tokenVencido || auth is! String || !auth.startsWith('Bearer tok-')) {
      return _json({'detail': auth == null ? 'Not authenticated' : 'No se pudo validar las credenciales'}, 401);
    }
    if (ruta == '/usuarios/me') {
      return _json({'id': usuarios.keys.toList().indexOf(auth.substring(11)) + 1, 'email': auth.substring(11)}, 200);
    }
    if (ruta == '/gastos/categorias') {
      return _json({'categorias': ['comida', 'transporte', 'entretenimiento', 'otros'], 'limite_por_categoria': 500.0}, 200);
    }
    if (ruta == '/gastos/' && o.method == 'GET') {
      return _json(gastos, 200, {'x-total-count': ['${gastos.length}']});
    }
    if (ruta == '/gastos/' && o.method == 'POST') {
      final b = jsonDecode(texto) as Map<String, dynamic>;
      final acumulado = gastos
          .where((g) => g['categoria'] == b['categoria'])
          .fold<double>(0, (suma, g) => suma + (g['monto'] as num));
      if (acumulado + (b['monto'] as num) > 500) {
        return _json({'detail': "Este gasto supera el límite de 500.0 para la categoría '${b['categoria']}'"}, 400);
      }
      final nuevo = {'id': _siguienteId++, 'fecha': '2026-10-08', ...b};
      gastos.add(nuevo);
      return _json(nuevo, 201);
    }
    final m = RegExp(r'^/gastos/(\d+)$').firstMatch(ruta);
    if (m != null) {
      final id = int.parse(m.group(1)!);
      final i = gastos.indexWhere((g) => g['id'] == id);
      if (i < 0) return _json({'detail': 'El gasto $id no existe'}, 404);
      if (o.method == 'PATCH') {
        gastos[i] = {...gastos[i], ...jsonDecode(texto) as Map<String, dynamic>};
        return _json(gastos[i], 200);
      }
      if (o.method == 'DELETE') {
        gastos.removeAt(i);
        return ResponseBody.fromString('', 204);
      }
    }
    return _json({'detail': 'ruta no prevista en la prueba: $ruta'}, 404);
  }

  @override
  void close({bool force = false}) {}
}

Future<void> _esperar(bool Function() condicion) async {
  for (var i = 0; i < 200 && !condicion(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  setUpAll(() => Hive.init(Directory.systemTemp.createTempSync('hive_s08').path));

  late _Servidor servidor;
  late ApiClient api;
  late AuthController auth;

  Future<void> montar({String? tokenGuardado}) async {
    Get.reset();
    Get.testMode = true;
    await Hive.deleteFromDisk();
    FlutterSecureStorage.setMockInitialValues({if (tokenGuardado != null) 'access_token': tokenGuardado});
    servidor = _Servidor();
    api = Get.put(ApiClient(dio: Dio(BaseOptions(baseUrl: 'http://prueba'))..httpClientAdapter = servidor));
    auth = Get.put(AuthController());
    await _esperar(() => !auth.restaurando.value);
  }

  Future<GastosController> conSesion() async {
    await auth.iniciarSesion('a@b.com', 'clave-1234');
    final g = Get.put(GastosController());
    await _esperar(() => g.categorias.isNotEmpty);
    await _esperar(() => g.estado.value.name == 'exito');
    return g;
  }

  test('Paso 2 — el interceptor agrega «Authorization: Bearer» a cada petición', () async {
    await montar();
    api.token = 'tok-a@b.com';
    await api.get('/usuarios/me');
    expect(servidor.peticiones.last.headers['Authorization'], 'Bearer tok-a@b.com');
  });

  test('Paso 2 — iniciar sesión (formulario) guarda el token y deja el usuario', () async {
    await montar();
    await auth.iniciarSesion('a@b.com', 'clave-1234');
    expect(auth.estaAutenticado, isTrue);
    expect(auth.usuario.value!.email, 'a@b.com');
    expect(await SecureTokenStorage().leer(), 'tok-a@b.com');
  });

  test('Paso 2 — contraseña incorrecta muestra el mensaje del servidor', () async {
    await montar();
    await auth.iniciarSesion('a@b.com', 'otra-clave-1');
    expect(auth.estaAutenticado, isFalse);
    expect(auth.mensajeError.value, 'Email o contraseña incorrectos');
  });

  test('Paso 3 — registrar crea la cuenta y entra', () async {
    await montar();
    await auth.registrar('nuevo@b.com', 'clave-1234');
    expect(servidor.usuarios.containsKey('nuevo@b.com'), isTrue);
    expect(auth.usuario.value?.email, 'nuevo@b.com');
  });

  test('Paso 3 — correo repetido muestra el detail del servidor', () async {
    await montar();
    await auth.registrar('a@b.com', 'clave-1234');
    expect(auth.estaAutenticado, isFalse);
    expect(auth.mensajeError.value, 'El email a@b.com ya está registrado');
  });

  test('Paso 4 — restaurar sesión con un token guardado válido', () async {
    await montar(tokenGuardado: 'tok-a@b.com');
    expect(auth.usuario.value?.email, 'a@b.com');
  });

  test('Paso 4 — restaurar sesión con un token caducado lo borra', () async {
    await montar(tokenGuardado: 'tok-viejo');
    servidor.usuarios.clear();
    Get.reset();
    FlutterSecureStorage.setMockInitialValues({'access_token': 'basura'});
    servidor = _Servidor();
    api = Get.put(ApiClient(dio: Dio(BaseOptions(baseUrl: 'http://prueba'))..httpClientAdapter = servidor));
    auth = Get.put(AuthController());
    await _esperar(() => !auth.restaurando.value);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(auth.estaAutenticado, isFalse);
    expect(await SecureTokenStorage().leer(), isNull);
    expect(auth.avisoSesion.value, 'Tu sesión caducó, inicia sesión de nuevo.');
  });

  test('Paso 5 — las categorías vienen del servidor', () async {
    await montar();
    final g = await conSesion();
    expect(g.categorias, ['comida', 'transporte', 'entretenimiento', 'otros']);
  });

  test('Paso 5 — crear un gasto lo guarda y refresca la lista', () async {
    await montar();
    final g = await conSesion();
    await g.crear('Almuerzo en el Mercado Central', 6.5, 'comida');
    expect(servidor.gastos.length, 1);
    expect(g.gastos.single.descripcion, 'Almuerzo en el Mercado Central');
  });

  test('Paso 5 — el límite de 500 llega como ApiException con el detail', () async {
    await montar();
    final g = await conSesion();
    await g.crear('Cena grande', 450, 'comida');
    expect(
      () => g.crear('Otra cena', 100, 'comida'),
      throwsA(predicate((e) => e.toString().contains('supera el límite de 500.0'))),
    );
  });

  test('Paso 6 — editar envía SOLO los campos que cambiaron', () async {
    await montar();
    final g = await conSesion();
    await g.crear('Taxi', 3.25, 'transporte');
    final id = g.gastos.single.id;
    await g.actualizar(id, {'monto': 4.0});
    expect(servidor.peticiones.where((p) => p.method == 'PATCH').single.data, {'monto': 4.0});
    expect(g.gastos.single.monto, 4.0);
    expect(g.gastos.single.descripcion, 'Taxi');
  });

  test('Paso 6 — eliminar quita el gasto de la lista', () async {
    await montar();
    final g = await conSesion();
    await g.crear('Taxi', 3.25, 'transporte');
    await g.eliminar(g.gastos.single.id);
    expect(servidor.gastos, isEmpty);
    expect(g.gastos, isEmpty);
  });

  test('Paso 6 — un 404 al eliminar refresca la lista', () async {
    await montar();
    final g = await conSesion();
    await g.crear('Taxi', 3.25, 'transporte');
    servidor.gastos.clear(); // alguien lo borró desde otro lado
    await expectLater(g.eliminar(1), throwsA(predicate((e) => e.toString().contains('no existe'))));
    expect(g.gastos, isEmpty);
  });

  test('Paso 7 — un 401 cierra la sesión y avisa que caducó', () async {
    await montar();
    final g = await conSesion();
    servidor.tokenVencido = true;
    await g.cargarGastos();
    // El interceptor avisa sin esperar: se da un instante a que cierre la sesión.
    await _esperar(() => !auth.estaAutenticado);
    expect(auth.estaAutenticado, isFalse);
    expect(await SecureTokenStorage().leer(), isNull);
    expect(auth.avisoSesion.value, 'Tu sesión caducó, inicia sesión de nuevo.');
  });

  test('Paso 8 — cerrar sesión borra la lista y la caja de Hive del usuario', () async {
    await montar();
    final g = await conSesion();
    await g.crear('Taxi', 3.25, 'transporte');
    expect(await Hive.boxExists('gastos_1'), isTrue);
    await auth.cerrarSesion();
    expect(g.gastos, isEmpty);
    expect(await Hive.boxExists('gastos_1'), isFalse);
  });
}
