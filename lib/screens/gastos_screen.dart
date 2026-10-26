import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/gastos_controller.dart';
import '../controllers/places_controller.dart' show EstadoCarga;
import '../models/gasto.dart';
import '../services/api_exception.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
// Solo los usan los bloques comentados de los Pasos 2, 5 y 9.
// ignore_for_file: unused_import
import '../widgets/sin_sesion_view.dart';
import 'cambiar_password_screen.dart';
import 'gasto_form_screen.dart';

/// Sección «Gastos del viaje» — Sesión 6. Desde la Sesión 8 solo se muestra
/// con sesión iniciada (si no, `SinSesionView`) y permite crear, editar y
/// eliminar gastos.
class GastosScreen extends GetView<GastosController> {
  const GastosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Obx(() {
      // Por qué: los gastos son de una persona concreta; sin sesión el servidor
      // respondería 401. El `Obx` lee `estaAutenticado`, así que la pantalla
      // cambia sola al iniciar o cerrar sesión.
      // TODO(sesion-08) Paso 2: descomenta la línea de abajo (pantalla sin sesión).
      // if (!auth.estaAutenticado) return const SinSesionView();
      return _buildGastos(context, auth);
    });
  }

  Widget _buildGastos(BuildContext context, AuthController auth) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('${'gastos'.tr} (${controller.totalEnServidor.value})')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: controller.cargarGastos,
          ),
          PopupMenuButton<String>(
            onSelected: (valor) {
              if (valor == 'salir') auth.cerrarSesion();
              if (valor == 'invalidar') auth.invalidarTokenParaPruebas();
              // Por qué: pantalla opcional del Paso 9 (cambiar contraseña).
              // TODO(sesion-08) OPCIONAL Paso 9: descomenta la línea de abajo (abrir la pantalla).
              // if (valor == 'password') Get.to(() => const CambiarPasswordScreen());
            },
            itemBuilder: (context) => [
              // TODO(sesion-08) OPCIONAL Paso 9: descomenta la línea de abajo (opción del menú).
              // const PopupMenuItem(value: 'password', child: Text('Cambiar contraseña')),
              const PopupMenuItem(value: 'salir', child: Text('Cerrar sesión')),
              if (kDebugMode)
                const PopupMenuItem(value: 'invalidar', child: Text('Invalidar token (solo práctica)')),
            ],
          ),
        ],
      ),
      // Por qué: el botón «+» abre el formulario vacío para crear un gasto.
      // TODO(sesion-08) Paso 5: descomenta las 4 líneas de abajo (botón «+»).
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => Get.to(() => const GastoFormScreen()),
      //   child: const Icon(Icons.add),
      // ),
      body: Obx(() {
        if (controller.estado.value == EstadoCarga.cargando) {
          return const LoadingView(mensaje: 'Cargando gastos...');
        }
        if (controller.estado.value == EstadoCarga.error) {
          return ErrorView(
            mensaje: controller.mensajeError.value,
            onReintentar: controller.iniciar,
          );
        }
        if (controller.gastos.isEmpty) {
          return const EmptyView(mensaje: 'Aún no registras gastos en este viaje');
        }
        return Column(
          children: [
            if (controller.desdeCache.value)
              MaterialBanner(
                leading: const Icon(Icons.cloud_off),
                content: Text(
                    'Sin conexión — gastos guardados (última sincronización: ${controller.ultimaSincronizacion})'),
                actions: [
                  TextButton(
                    onPressed: controller.cargarGastos,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.cargarGastos,
                child: _buildLista(context, controller.gastos),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLista(BuildContext context, List<Gasto> gastos) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: gastos.length,
      itemBuilder: (context, i) {
        final g = gastos[i];
        return ListTile(
          title: Text(g.descripcion),
          subtitle: Text('${g.categoria} · ${g.fecha}'),
          // Por qué: tocar una fila abre el mismo formulario, ya relleno.
          // TODO(sesion-08) Paso 6: descomenta la línea de abajo (tocar para editar).
          // onTap: () => Get.to(() => GastoFormScreen(gasto: g)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(g.monto.toStringAsFixed(2), style: Theme.of(context).textTheme.titleMedium),
              // TODO(sesion-08) Paso 6: descomenta las 5 líneas de abajo (botón de eliminar).
              // IconButton(
              //   icon: const Icon(Icons.delete_outline),
              //   tooltip: 'Eliminar',
              //   onPressed: () => confirmarEliminar(context, g),
              // ),
            ],
          ),
        );
      },
    );
  }

  /// Pide confirmación antes de borrar; si el servidor falla, avisa con el
  /// mensaje que devolvió.
  Future<void> confirmarEliminar(BuildContext context, Gasto g) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: Text('¿Eliminar "${g.descripcion}"?'),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogo, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(dialogo, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmado != true) return;
    try {
      await controller.eliminar(g.id);
    } on ApiException catch (e) {
      Get.snackbar('No se pudo eliminar', e.mensaje);
    }
  }
}
