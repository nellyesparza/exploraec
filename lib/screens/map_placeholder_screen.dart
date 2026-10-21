import 'package:flutter/material.dart';

/// Placeholder de la pestaña Mapa — Sesión 2. Se reemplaza por un mapa
/// real (flutter_map + OpenStreetMap) en la Sesión 5.
class MapPlaceholderScreen extends StatelessWidget {
  const MapPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: const Center(
        child: Text(
          'Próximamente: mapa real (Sesión 5)',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
