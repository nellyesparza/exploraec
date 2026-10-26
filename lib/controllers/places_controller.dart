import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../models/place.dart';
import '../services/location_service.dart';

enum EstadoCarga { cargando, exito, error }

/// Fuente única de verdad de los lugares, la posición y los favoritos —
/// Sesiones 4, 5 y 7. La lista (`lugares`) y su estado de carga nacieron en la
/// Sesión 4 para `HomeScreen`; desde la Sesión 5 el controller también
/// guarda la posición real (`posicion`, con su propio estado) para que el
/// Mapa —y, en la Sesión 6, la consulta a la Overpass API— la lean sin
/// pedirla de nuevo al sistema operativo.
class PlacesController extends GetxController {
  final RxList<Place> lugares = <Place>[].obs;
  final Rx<EstadoCarga> estado = EstadoCarga.cargando.obs;
  final RxString mensajeError = ''.obs;
  final Rx<Position?> posicion = Rx<Position?>(null);
  final Rx<EstadoCarga> estadoPosicion = EstadoCarga.cargando.obs;
  final RxString mensajeErrorPosicion = ''.obs;

  /// Estado derivado (Sesión 4, Paso 5): se calcula a partir de `lugares`.
  int get total => lugares.length;

  /// Worker (Sesión 4, Paso 5): reacciona a cada cambio de `estado`.
  void _observarErrores() {
    ever(estado, (EstadoCarga e) {
      if (e == EstadoCarga.error) {
        Get.snackbar('Error', mensajeError.value);
      }
    });
  }

  bool _modoDebugError = false;
  bool _modoDebugVacio = false;

  @override
  void onInit() {
    _observarErrores();
    super.onInit();
    // Sesión 7: los favoritos guardados en Hive se cargan al arrancar.
    favoritos.value = _favoritosBox.values
        .map((mapa) => Place.fromMap(Map<String, dynamic>.from(mapa)))
        .toList();
    cargarLugares();
  }

  /// Simula uno de los 3 estados a propósito, solo para esta práctica —
  /// mismo recurso que `HomeScreen` traía desde la Sesión 3, ahora
  /// centralizado aquí para que cualquier pantalla pueda mostrarlos.
  void simular(String modo) {
    _modoDebugError = modo == 'error';
    _modoDebugVacio = modo == 'vacio';
    cargarLugares();
  }

  Future<void> cargarLugares() async {
    estado.value = EstadoCarga.cargando;
    try {
      final resultado = await fetchLugaresSimulado(
        forzarError: _modoDebugError,
        forzarVacio: _modoDebugVacio,
      );
      lugares.assignAll(resultado);
      estado.value = EstadoCarga.exito;
    } catch (e) {
      mensajeError.value = '$e';
      estado.value = EstadoCarga.error;
    }
  }

  /// Pide la posición real al sistema operativo una sola vez y la deja en
  /// [posicion]; si ya la tiene, no vuelve a pedirla salvo que se pida con
  /// [forzar] (por ejemplo, desde el botón "Reintentar" del Mapa).
  Future<void> cargarPosicion({bool forzar = false}) async {
    if (posicion.value != null && !forzar) {
      estadoPosicion.value = EstadoCarga.exito;
      return;
    }
    estadoPosicion.value = EstadoCarga.cargando;
    try {
      posicion.value = await LocationService.obtenerPosicionActual();
      estadoPosicion.value = EstadoCarga.exito;
    } on LocationException catch (e) {
      mensajeErrorPosicion.value = e.mensaje;
      estadoPosicion.value = EstadoCarga.error;
    } catch (e) {
      mensajeErrorPosicion.value = '$e';
      estadoPosicion.value = EstadoCarga.error;
    }
  }

  /// Agrega un lugar creado a mano (`AddPlaceScreen`) — en memoria
  /// únicamente: no se guarda en Hive a propósito (solo se guardan los
  /// favoritos). `lugares.add` (en vez de reconstruir toda la lista) ya
  /// notifica a cualquier `Obx` que esté escuchando, en Inicio y en el Mapa
  /// a la vez.
  void agregarLugar(Place lugar) {
    lugaresEjemplo.add(lugar);
    lugares.add(lugar);
  }

  /// Favoritos — Sesión 4 (en memoria) y Sesión 7 (persistentes). `_favoritosBox`
  /// es el almacenamiento (sobrevive reiniciar la app; `main()` ya la abrió);
  /// `favoritos` es el espejo reactivo que la UI observa con `Obx` — el
  /// patrón «Hive guarda, Rx notifica».
  final RxList<Place> favoritos = <Place>[].obs;
  final Box<Map> _favoritosBox = Hive.box<Map>('favoritos');

  bool esFavorito(Place lugar) => favoritos.any((p) => p.id == lugar.id);

  /// Otro estado derivado: se calcula a partir de `favoritos`, no se guarda.
  int get totalFavoritos => favoritos.length;

  /// Favoritos persistentes (Sesión 7): primero Hive, luego el espejo reactivo.
  void alternarFavorito(Place lugar) {
    if (esFavorito(lugar)) {
      _favoritosBox.delete(lugar.id);
      favoritos.removeWhere((p) => p.id == lugar.id);
    } else {
      _favoritosBox.put(lugar.id, lugar.toMap());
      favoritos.add(lugar);
    }
  }

  double? distanciaA(Place lugar) {
    final pos = posicion.value;
    return pos == null ? null : distanciaAPlaceEnMetros(pos, lugar);
  }
}
