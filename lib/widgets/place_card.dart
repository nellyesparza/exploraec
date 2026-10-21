import 'package:flutter/material.dart';
import '../models/place.dart';
import '../screens/detail_screen.dart';

/// Tarjeta reutilizable que representa un [Place] en cualquier lista de
/// la app (Inicio, resultados de categoría, etc.) — Sesión 2.
class PlaceCard extends StatelessWidget {
  final Place place;
  const PlaceCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        // TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo. (Paso 6 — navegación al Detalle)
        // Por qué: sin este onTap la tarjeta se ve pero no lleva a
        // ningún lado — Navigator.push agrega DetailScreen encima de
        // la pila, pasándole el Place ya completo por su constructor.

        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(place: place)),
        ),

        // TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo. (Paso 5 — cuerpo de la tarjeta)
        // Por qué: el Padding con texto fijo de abajo es solo un
        // placeholder que compila — el Row/Column real es la misma
        // composición Card+Row+Column+Text vista en teoría, con el
        // nombre envuelto en Expanded para que nunca desborde.

        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.place, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.nombre,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(place.categoria,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    Text(
                      place.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
