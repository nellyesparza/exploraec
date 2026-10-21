import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/places_controller.dart';

/// Placeholder de la pestaña Favoritos — Sesión 2. Se reemplaza por
/// favoritos persistentes con Hive en la Sesión 7. Desde el Paso 6
/// (opcional) de la Sesión 4 ya lee el contador del mismo controller que
/// Inicio: prueba de que otra pantalla comparte el estado.
class FavoritesPlaceholderScreen extends StatelessWidget {
  const FavoritesPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlacesController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: Center(
        child: Obx(
          () => Text(
            'Favoritos marcados: ${controller.totalFavoritos}.\nSe guardarán de verdad en la Sesión 7.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
