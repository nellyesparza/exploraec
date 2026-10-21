import 'package:get/get.dart';

import '../controllers/places_controller.dart';

/// Registra las dependencias que la app necesita desde el arranque —
/// Sesión 4. Con un solo controller por ahora alcanza un binding simple;
/// si una sesión futura agrega otro controller (por ejemplo, autenticación
/// en la Sesión 8), puede sumarse aquí mismo o en un binding propio por
/// pantalla, según convenga en ese momento — no se anticipa esa estructura
/// hoy sin necesitarla todavía.
class PlacesBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PlacesController());
  }
}
