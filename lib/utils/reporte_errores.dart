// Solo lo usa el bloque comentado del Paso 2 (la vista amistosa).
// ignore_for_file: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/error_pantalla_view.dart';

/// Qué hace la app con los errores que nadie esperaba — Sesión 10. Hay tres
/// puertas por donde se escapa un error no controlado: el propio framework
/// (un widget que falla al construirse), el código asíncrono (un `Future` sin
/// `catch`) y la pantalla roja de depuración. `instalar()` las conecta a un
/// único lugar: `registrar`.
class ReporteErrores {
  ReporteErrores._();

  /// Últimos mensajes registrados (ya limpios). Sirven para las pruebas.
  static final List<String> recientes = [];

  /// Quita de un texto lo que NUNCA debe quedar en un registro: cabeceras
  /// `Bearer` y tokens JWT (tres partes separadas por puntos).
  static String limpiar(String texto) => texto
      .replaceAll(RegExp(r'Bearer\s+[A-Za-z0-9\-._~+/]+=*'), 'Bearer ***')
      .replaceAll(RegExp(r'eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]*'), '***');

  /// Guarda el error ya limpio. En una app real, aquí se enviaría a un servicio
  /// de monitoreo (por ejemplo, Crashlytics o Sentry) — con el mensaje limpio.
  static void registrar(Object error, StackTrace? pila) {
    final mensaje = limpiar('${error.runtimeType}: $error');
    recientes.add(mensaje);
    if (recientes.length > 20) recientes.removeAt(0);
    debugPrint('[ExploraEC] error no controlado -> $mensaje');
  }

  /// Avisa a la persona sin mostrar nada técnico (si la app ya tiene navegación).
  static void avisar() {
    // Un aviso nunca debe romper el propio manejo de errores: si no se puede
    // mostrar (la app aún no tiene navegación), simplemente se omite.
    try {
      if (Get.key.currentState == null) return;
      Get.snackbar('Algo salió mal', 'Ya registramos el problema. Puedes seguir usando la app.');
    } catch (_) {}
  }

  /// Conecta las tres puertas. Se llama una sola vez, desde `main()`.
  static void instalar() {
    // Por qué: sin esto, un widget que falla muestra la pantalla roja de
    // depuración (o una caja gris en la versión final) y un error asíncrono
    // solo deja una línea en la consola. Con esto, los dos terminan en
    // `registrar`, y la persona ve una vista amistosa en vez de una traza.
    // TODO(sesion-10) Paso 2: descomenta las 10 líneas de abajo (capturar errores no controlados).
    // FlutterError.onError = (detalles) {
    //   FlutterError.presentError(detalles);
    //   registrar(detalles.exception, detalles.stack);
    // };
    // PlatformDispatcher.instance.onError = (error, pila) {
    //   registrar(error, pila);
    //   avisar();
    //   return true;
    // };
    // ErrorWidget.builder = (detalles) => const ErrorPantallaView();
  }
}
