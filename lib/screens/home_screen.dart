import 'package:flutter/material.dart';
import '../models/place.dart';
import '../widgets/place_card.dart';
import 'add_place_screen.dart';

/// Pantalla de Inicio: lista de lugares de ejemplo — Sesión 2.
/// Desde la Sesión 6, esta misma pantalla muestra lugares reales.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ExploraEC')),
      // TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo.
      // Por qué: el Center de abajo es solo un placeholder — el
      // ListView.builder real recorre lugaresEjemplo y dibuja un
      // PlaceCard por cada lugar, construyendo únicamente los ítems
      // visibles en pantalla, no la lista completa de una vez.

      body: ListView.builder(
        itemCount: lugaresEjemplo.length,
        itemBuilder: (context, index) =>
            PlaceCard(place: lugaresEjemplo[index]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlaceScreen()),
          );
          setState(() {}); // refresca la lista al volver del formulario
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
