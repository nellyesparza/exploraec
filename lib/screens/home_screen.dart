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
import '../services/settings_service.dart';

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
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: 'idioma'.tr,
            onPressed: SettingsService.alternarIdioma,
          ),
          PopupMenuButton<String>(
            tooltip: 'Simular estado (solo práctica)',
            onSelected: controller.simular,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'normal', child: Text('sim_normal'.tr)),
              PopupMenuItem(value: 'vacio', child: Text('sim_vacio'.tr)),
              PopupMenuItem(value: 'error', child: Text('sim_error'.tr)),
            ],
          ),
        ],
      ),
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
