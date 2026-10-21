import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/places_controller.dart';
import '../models/place.dart';
import '../theme/app_theme.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import 'detail_screen.dart';

/// Pantalla de Mapa real — Sesión 5. Reemplaza a `MapPlaceholderScreen`
/// (Sesión 2). Teselas de OpenStreetMap, sin API key: ver la política de
/// uso de tiles de OSM citada en la teoría de esta sesión. Lee del mismo
/// `PlacesController` que `HomeScreen` (Sesión 4): los lugares salen de
/// `controller.lugares` y la posición se guarda en `controller.posicion`,
/// de modo que se pide al sistema operativo una sola vez.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final controller = Get.find<PlacesController>();
  final mapController = MapController();

  @override
  void initState() {
    super.initState();
    controller.cargarPosicion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: Obx(() {
        if (controller.estadoPosicion.value == EstadoCarga.cargando) {
          return const LoadingView(mensaje: 'Obteniendo tu ubicación...');
        }
        if (controller.estadoPosicion.value == EstadoCarga.error) {
          return ErrorView(
            mensaje: controller.mensajeErrorPosicion.value,
            onReintentar: () => controller.cargarPosicion(forzar: true),
          );
        }
        return _buildMapa(
            context, controller.posicion.value!, controller.lugares);
      }),
      // TODO(sesion-05): OPCIONAL — descomenta el bloque de abajo (Paso 7A — centrar el mapa). No borres nada.
      // Por qué: el `mapController` de arriba ya está conectado al
      // `FlutterMap`; este botón lo usa como "control remoto" para volver
      // a la posición del usuario con `move(...)` después de arrastrar el
      // mapa, sin que la persona tenga que buscarse a mano.
      floatingActionButton: FloatingActionButton(
        tooltip: 'Centrar en mi ubicación',
        onPressed: () {
          final pos = controller.posicion.value;
          if (pos == null) return;
          mapController.move(LatLng(pos.latitude, pos.longitude), 15);
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildMapa(
      BuildContext context, Position posicion, List<Place> lugares) {
    final miUbicacion = LatLng(posicion.latitude, posicion.longitude);
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(initialCenter: miUbicacion, initialZoom: 15),
      children: [
        // La política de uso de tiles de OSM exige un userAgentPackageName
        // real que identifique la app — no dejar el valor de ejemplo del
        // paquete en una app publicada.
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.tmo.exploraec',
        ),
        // TODO(sesion-05): borra la línea de abajo y descomenta el bloque completo. (Paso 4 — marcadores)
        // Por qué: sin marcadores el mapa se ve pero no comunica nada —
        // el bloque real agrega uno para la posición del usuario y uno
        // por cada Place que expone el controller, cada uno navegando al
        // Detalle (con la distancia ya calculada) al tocarlo.
        // const MarkerLayer(markers: []),
        MarkerLayer(
          markers: [
            Marker(
              point: miUbicacion,
              width: 40,
              height: 40,
              child:
                  const Icon(Icons.my_location, color: Colors.blue, size: 32),
            ),
            ...lugares.map(
              (lugar) => Marker(
                point: LatLng(lugar.lat, lugar.lng),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () => Get.to(() => DetailScreen(
                        place: lugar,
                        distanciaMetros: controller.distanciaA(lugar),
                      )),
                  child: Icon(Icons.place,
                      color: AppTheme.colorPrimario, size: 36),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
