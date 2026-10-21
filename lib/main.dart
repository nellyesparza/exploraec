import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/map_placeholder_screen.dart';
import 'screens/favorites_placeholder_screen.dart';

void main() {
  runApp(const ExploraEcApp());
}

class ExploraEcApp extends StatelessWidget {
  const ExploraEcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExploraEC',
      home: const RootShell(),
    );
  }
}

/// Contenedor raíz con la barra de navegación inferior — Sesión 2.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _indiceActual = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo. (cuerpo según pestaña)
      // Por qué: un body fijo en HomeScreen ignoraría qué pestaña está
      // activa — este switch sobre _indiceActual es lo que hace que
      // BottomNavigationBar (más abajo) realmente cambie de contenido
      // al tocar cada pestaña, en vez de solo resaltarla.

      body: switch (_indiceActual) {
        0 => const HomeScreen(),
        1 => const MapPlaceholderScreen(),
        _ => const FavoritesPlaceholderScreen(),
      },

      // TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo. (barra inferior)
      // Por qué: sin este widget no hay pestañas que tocar — junto con
      // el switch de arriba, BottomNavigationBar alterna entre
      // Inicio/Mapa/Favoritos sin apilarlas como haría Navigator.push.

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (i) => setState(() => _indiceActual = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favoritos'),
        ],
      ),
    );
  }
}
