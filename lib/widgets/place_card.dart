import 'package:flutter/material.dart';
import '../models/place.dart';
import '../screens/detail_screen.dart';
import '../theme/app_theme.dart';

/// Tarjeta reutilizable que representa un [Place] en cualquier lista de
/// la app (Inicio, resultados de categoría, etc.) — Sesión 2.
/// Accesibilidad y colores de marca aplicados en la Sesión 3.
class PlaceCard extends StatelessWidget {
  final Place place;
  const PlaceCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(place: place)),
        ),
        // TODO(sesion-03): borra la línea de abajo y descomenta el bloque completo. (Paso 5 — accesibilidad)
        // Por qué: sin Semantics, un lector de pantalla solo anuncia los
        // textos sueltos de la tarjeta, sin contexto — el label/hint de
        // abajo describe la tarjeta completa como un solo elemento
        // interactivo, con instrucción de qué hace al tocarla.
        // excludeSemantics: true evita que el lector de pantalla, además del
        // label de abajo, vuelva a leer el nombre/categoría/descripción de
        // _buildContenido() por separado — sin esa línea se anuncian los dos
        // a la vez, uno detrás del otro.

        child: Semantics(
          label: '${place.nombre}, categoría ${place.categoria}',
          hint: 'Toca dos veces para ver el detalle',
          button: true,
          excludeSemantics: true,
          child: _buildContenido(context),
        ),
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
                Text(
                  place.nombre,
                  style: estilos.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(place.categoria,
                    style: estilos.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
