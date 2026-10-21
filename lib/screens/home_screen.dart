import 'package:flutter/material.dart';
import '../models/place.dart';
import '../widgets/place_card.dart';
import '../widgets/loading_view.dart';
import '../widgets/empty_view.dart';
import '../widgets/error_view.dart';
import '../theme/app_theme.dart';
import 'add_place_screen.dart';

/// Pantalla de Inicio: lista de lugares — Sesión 2 (datos de ejemplo).
/// Desde la Sesión 3, la carga pasa por una función simulada con estados
/// loading/vacío/error y un layout responsivo. Desde la Sesión 6, esta
/// misma pantalla consume la Overpass API real, sin cambiar su estructura.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Place>> _futuroLugares;
  bool _modoDebugError = false;
  bool _modoDebugVacio = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  /// Dispara (o vuelve a disparar) la carga. [_modoDebugError]/[_modoDebugVacio]
  /// son solo un recurso de esta práctica, para demostrar los 3 estados sin
  /// depender de una red real — no existen en la versión final de la app.
  void _cargar() {
    setState(() {
      _futuroLugares = fetchLugaresSimulado(
          forzarError: _modoDebugError, forzarVacio: _modoDebugVacio);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ExploraEC'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Simular estado (solo práctica)',
            onSelected: (valor) {
              _modoDebugError = valor == 'error';
              _modoDebugVacio = valor == 'vacio';
              _cargar();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'normal', child: Text('Simular: normal')),
              PopupMenuItem(value: 'vacio', child: Text('Simular: vacío')),
              PopupMenuItem(value: 'error', child: Text('Simular: error')),
            ],
          ),
        ],
      ),
      // TODO(sesion-03): borra la línea de abajo y descomenta el bloque completo. (Paso 3 — estados loading/vacío/error)
      // Por qué: el Center fijo de abajo no distingue entre "cargando",
      // "vacío" y "falló" — el FutureBuilder real inspecciona el estado
      // del snapshot y dibuja LoadingView/ErrorView/EmptyView según
      // corresponda, para que la pantalla nunca quede en blanco.

      body: FutureBuilder<List<Place>>(
        future: _futuroLugares,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView(mensaje: 'Buscando lugares cercanos...');
          }
          if (snapshot.hasError) {
            return ErrorView(
                mensaje: '${snapshot.error}', onReintentar: _cargar);
          }
          final lugares = snapshot.data ?? [];
          if (lugares.isEmpty) {
            return const EmptyView(mensaje: 'Todavía no hay lugares guardados');
          }
          return _buildLista(lugares);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlaceScreen()),
          );
          _cargar();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // TODO(sesion-03): borra la línea de abajo y descomenta el bloque completo. (Paso 4 — layout responsivo)
  // Por qué: el ListView.builder de abajo es siempre una sola columna,
  // sin importar el ancho de pantalla — la versión real usa
  // LayoutBuilder para leer el ancho disponible y elegir ListView
  // (teléfono angosto) o GridView de 2-3 columnas (pantalla ancha).

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
