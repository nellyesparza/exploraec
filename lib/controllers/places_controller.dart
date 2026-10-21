import 'package:get/get.dart';

import '../models/place.dart';

enum EstadoCarga { cargando, exito, error }

/// Fuente única de verdad de los lugares — Sesión 4. Antes de esta sesión el
/// estado de la lista (su `Future`, las banderas de simulación y el
/// `setState`) vivía atrapado dentro de `HomeScreen`, y la pantalla se
/// enteraba de un lugar nuevo solo recargando a mano al volver del
/// formulario. Ahora vive aquí, registrado una sola vez por
/// `PlacesBinding` y obtenido con `Get.find()` (vía `GetView`, ver
/// `HomeScreen`): cualquier pantalla futura lo lee sin repetir esa carga.
class PlacesController extends GetxController {
  final RxList<Place> lugares = <Place>[].obs;
  final Rx<EstadoCarga> estado = EstadoCarga.cargando.obs;
  final RxString mensajeError = ''.obs;

  bool _modoDebugError = false;
  bool _modoDebugVacio = false;

  @override
  void onInit() {
    super.onInit();
    cargarLugares();

    ever(estado, (EstadoCarga e) {
      if (e == EstadoCarga.error) {
        Get.snackbar('Error', mensajeError.value);
      }
    });
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

    // TODO(sesion-04): borra las dos líneas de abajo y descomenta el bloque completo. (Paso 2 — conectar el controller a la carga de lugares)
    // Por qué: las 2 líneas de abajo fuerzan éxito con una lista vacía,
    // sin llamar a nada — el bloque try/catch real es exactamente la
    // misma lógica que `HomeScreen._cargar()` tenía en la Sesión 3
    // (llamar a `fetchLugaresSimulado` y traducir su resultado a los 3
    // estados), ahora centralizada aquí para que cualquier pantalla la
    // comparta en vez de cada una tener la suya. Se usa `assignAll` (y no
    // `lugares.value = resultado`) porque copia los elementos:
    // `fetchLugaresSimulado` devuelve la lista global `lugaresEjemplo`, y
    // asignarla directo haría que `lugares` y `lugaresEjemplo` fueran la
    // misma lista, con lo que `agregarLugar` duplicaría cada lugar nuevo.

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

  /// Agrega un lugar creado a mano (`AddPlaceScreen`) — en memoria
  /// únicamente hasta que la Sesión 7 lo persista con Hive. `lugares.add`
  /// (en vez de reconstruir toda la lista) ya notifica a cualquier `Obx`
  /// que esté escuchando: Inicio se actualiza solo, sin el `_cargar()`
  /// manual que la Sesión 3 hacía al volver del formulario.
  void agregarLugar(Place lugar) {
    lugaresEjemplo.add(lugar);
    lugares.add(lugar);
  }

  /// Favoritos en memoria — Paso 6 (opcional). Viven solo mientras la app
  /// está abierta; la Sesión 7 los persiste con Hive, sin cambiar los
  /// nombres de abajo (`favoritos`, `esFavorito`, `alternarFavorito`).
  final RxList<Place> favoritos = <Place>[].obs;

  bool esFavorito(Place lugar) => favoritos.any((p) => p.id == lugar.id);

  /// Otro estado derivado: se calcula a partir de `favoritos`, no se guarda.
  int get totalFavoritos => favoritos.length;
  int get total => lugares.length;

  // TODO(sesion-04): OPCIONAL — borra la línea de abajo y descomenta el bloque completo. (Paso 6A — favoritos en memoria)
  // Por qué: el método vacío de abajo no hace nada, por eso el corazón de
  // `PlaceCard` no cambia al tocarlo. La versión real agrega o quita el
  // lugar de la lista reactiva `favoritos`: cualquier `Obx` que la lea (el
  // ícono del corazón, el contador de la pestaña Favoritos) se actualiza solo.

  void alternarFavorito(Place lugar) {
    if (esFavorito(lugar)) {
      favoritos.removeWhere((p) => p.id == lugar.id);
    } else {
      favoritos.add(lugar);
    }
  }
}
