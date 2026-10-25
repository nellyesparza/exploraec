import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/places_controller.dart';
import '../widgets/empty_view.dart';
import '../widgets/place_card.dart';

/// Favoritos persistentes con Hive — Sesión 7. Reemplaza el placeholder
/// fijo de la Sesión 2: ahora lee `controller.favoritos`, la lista
/// reactiva respaldada por la caja de Hive que sobrevive reiniciar la app
/// (ver `PlacesController`).
class FavoritesScreen extends GetView<PlacesController> {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: Obx(() {
        if (controller.favoritos.isEmpty) {
          return const EmptyView(
            mensaje: 'Todavía no marcaste ningún lugar como favorito.\n'
                'Toca el corazón en cualquier tarjeta para guardarlo aquí.',
            icono: Icons.favorite_border,
          );
        }
        return ListView.builder(
          itemCount: controller.favoritos.length,
          itemBuilder: (context, index) => PlaceCard(place: controller.favoritos[index]),
        );
      }),
    );
  }
}
