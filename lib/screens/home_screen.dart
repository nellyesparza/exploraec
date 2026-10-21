import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/places_controller.dart';
import '../models/place.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/place_card.dart';
import 'add_place_screen.dart';

/// Pantalla de Inicio: lista de lugares — Sesión 2. Desde la Sesión 4 ya
/// no mantiene su propio `Future`/`setState`: `GetView<PlacesController>`
/// da acceso directo al controller ya registrado por `PlacesBinding`
/// (equivalente a `Get.find<PlacesController>()`, pero sin repetirlo en
/// cada método), y `Obx` reconstruye la pantalla sola cuando el controller
/// cambia. Las próximas pantallas (Mapa en la Sesión 5, Favoritos en la
/// Sesión 7) leen del mismo controller.
class HomeScreen extends GetView<PlacesController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('ExploraEC (${controller.total})')),
        actions: [
          // TODO(sesion-04): OPCIONAL — descomenta el bloque de abajo (Paso 6B — idioma). No borres nada.
          // Por qué: `Get.updateLocale` cambia el idioma activo y reconstruye
          // la app entera sin `setState` ni `context`: es estado global, igual
          // que `PlacesController`, pero manejado por el propio GetX.
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: 'idioma'.tr,
            onPressed: () {
              final esEspanol = Get.locale?.languageCode == 'es';
              Get.updateLocale(esEspanol
                  ? const Locale('en', 'US')
                  : const Locale('es', 'EC'));
            },
          ),
          PopupMenuButton<String>(
            tooltip: 'Simular estado (solo práctica)',
            onSelected: controller.simular,
            // TODO(sesion-04): OPCIONAL — borra el bloque `itemBuilder` de abajo y descomenta el bloque completo. (Paso 6B — idioma)
            // Por qué: igual que en la barra inferior, el texto pasa a
            // `.tr` y la lista deja de ser `const`.

            itemBuilder: (context) => [
              PopupMenuItem(value: 'normal', child: Text('sim_normal'.tr)),
              PopupMenuItem(value: 'vacio', child: Text('sim_vacio'.tr)),
              PopupMenuItem(value: 'error', child: Text('sim_error'.tr)),
            ],
          ),
        ],
      ),
      // TODO(sesion-04): borra la línea de abajo y descomenta el bloque completo. (Paso 3 — reactividad con Obx)
      // Por qué: el texto fijo de abajo nunca cambia porque nada lo
      // observa — Obx reconstruye automáticamente su contenido cada vez
      // que una variable Rx que lee (controller.estado, controller.lugares)
      // cambia, sin necesitar setState ni StatefulWidget en esta pantalla.

      body: Obx(() {
        if (controller.estado.value == EstadoCarga.cargando) {
          return const LoadingView(mensaje: 'Buscando lugares cercanos...');
        }
        if (controller.estado.value == EstadoCarga.error) {
          return ErrorView(
            mensaje: controller.mensajeError.value,
            onReintentar: controller.cargarLugares,
          );
        }
        if (controller.lugares.isEmpty) {
          return const EmptyView(mensaje: 'Todavía no hay lugares guardados');
        }
        return _buildLista(controller.lugares);
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddPlaceScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLista(List<Place> lugares) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return ListView.builder(
            itemCount: lugares.length,
            itemBuilder: (context, index) => PlaceCard(place: lugares[index]),
          );
        }
        final columnas = constraints.maxWidth < 900 ? 2 : 3;
        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.sm),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnas,
            childAspectRatio: 2.2,
          ),
          itemCount: lugares.length,
          itemBuilder: (context, index) => PlaceCard(place: lugares[index]),
        );
      },
    );
  }
}
