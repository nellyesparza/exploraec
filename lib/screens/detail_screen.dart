import 'package:flutter/material.dart';
import '../models/place.dart';

/// Pantalla de Detalle: recibe un [Place] completo por su constructor,
/// sin volver a consultar ninguna lista — Sesión 2.
class DetailScreen extends StatelessWidget {
  final Place place;
  const DetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(place.nombre)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place.nombre,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Chip(label: Text(place.categoria)),
            const SizedBox(height: 16),
            Text(place.descripcion, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
