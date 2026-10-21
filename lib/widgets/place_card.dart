import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/places_controller.dart';
import '../models/place.dart';
import '../screens/detail_screen.dart';
import '../theme/app_theme.dart';
// TODO(sesion-05): OPCIONAL — descomenta la línea de abajo (Paso 7B — distancia en Inicio). No borres nada.
import '../services/location_service.dart';

/// Tarjeta reutilizable que representa un [Place] en cualquier lista de
/// la app (Inicio, resultados de categoría, etc.) — Sesión 2.
/// Accesibilidad y colores de marca aplicados en la Sesión 3. Navegación
/// con GetX (`Get.to`) desde la Sesión 4, en vez de `Navigator.push` +
/// `MaterialPageRoute` — Flutter sigue usando `Navigator` por debajo,
/// `Get.to` solo evita repetir `MaterialPageRoute(builder: ...)` en cada
/// lugar que navega, y no pide `context` para hacerlo. El corazón de
/// favorito (Paso 6 opcional de la Sesión 4) lee `PlacesController` con
/// `Get.find` y se repinta solo con `Obx`.
class PlaceCard extends StatelessWidget {
  final Place place;
  const PlaceCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlacesController>();
    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Stack(
        children: [
          InkWell(
            onTap: () => Get.to(() => DetailScreen(place: place)),
            child: Semantics(
              label: '${place.nombre}, categoría ${place.categoria}',
              hint: 'Toca dos veces para ver el detalle',
              button: true,
              excludeSemantics: true,
              child: _buildContenido(context),
            ),
          ),
          Positioned(
            right: AppSpacing.xs,
            top: AppSpacing.xs,
            child: Obx(
              () => IconButton(
                icon: Icon(
                  controller.esFavorito(place)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color:
                      controller.esFavorito(place) ? Colors.red : Colors.grey,
                ),
                tooltip: controller.esFavorito(place)
                    ? 'Quitar de favoritos'
                    : 'Agregar a favoritos',
                onPressed: () => controller.alternarFavorito(place),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContenido(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.place,
              size: 32, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: Text(
                    place.nombre,
                    style: estilos.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(place.categoria,
                    style: estilos.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                // TODO(sesion-05): OPCIONAL — descomenta el bloque de abajo (Paso 7B — distancia en Inicio). No borres nada.
                // Por qué: `distanciaA` devuelve null mientras el controller
                // no tiene la posición (antes de abrir el Mapa), así que el
                // `Obx` no pinta nada; apenas `posicion` se llena, todas las
                // tarjetas muestran la distancia sin recargar la lista.
                Obx(() {
                  final metros = Get.find<PlacesController>().distanciaA(place);
                  if (metros == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Row(
                      children: [
                        const Icon(Icons.near_me, size: 14),
                        const SizedBox(width: AppSpacing.xs),
                        Text('A ${formatearDistancia(metros)} de ti',
                            style: estilos.bodySmall),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  place.descripcion,
                  style: estilos.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
