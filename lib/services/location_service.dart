import 'package:geolocator/geolocator.dart';

import '../models/place.dart';

/// Ubicación real del dispositivo — Sesión 5.
///
/// Encapsula el flujo completo (servicio de ubicación del sistema encendido
/// → permiso concedido → posición actual) en un solo método que lanza
/// [LocationException] con un mensaje ya listo para mostrar en pantalla,
/// para que la UI (`MapScreen`) no tenga que conocer los detalles de
/// `geolocator`/`permission_handler`.
class LocationException implements Exception {
  final String mensaje;
  LocationException(this.mensaje);

  @override
  String toString() => mensaje;
}

class LocationService {
  LocationService._();

  static Future<Position> obtenerPosicionActual() async {
    final servicioActivo = await Geolocator.isLocationServiceEnabled();
    if (!servicioActivo) {
      throw LocationException(
        'La ubicación está desactivada en el dispositivo. Actívala en Ajustes y vuelve a intentar.',
      );
    }

    // TODO(sesion-05): borra la línea de abajo y descomenta el bloque completo. (Paso 3 — solicitar permiso)
    // Por qué: dejar el permiso fijo en "denied" abajo es lo que hace
    // que la app siempre muestre el error de permiso denegado hasta
    // completar este paso — el bloque real primero consulta el permiso
    // actual y, si está denegado, recién ahí lo solicita al usuario
    // (nunca se solicita un permiso que ya fue concedido antes).

    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    if (permiso == LocationPermission.denied) {
      throw LocationException(
          'Permiso de ubicación denegado. ExploraEC lo necesita para mostrarte lugares cercanos.');
    }
    if (permiso == LocationPermission.deniedForever) {
      throw LocationException(
        'Permiso de ubicación bloqueado permanentemente. Actívalo manualmente desde Ajustes de la app.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }
}

/// Distancia entre la posición actual y un [Place], en metros — usa la
/// fórmula de Haversine que ya trae `geolocator`, sin reimplementarla.
double distanciaAPlaceEnMetros(Position origen, Place destino) {
  return Geolocator.distanceBetween(
      origen.latitude, origen.longitude, destino.lat, destino.lng);
}

/// Formatea una distancia en metros a un texto corto y legible.
String formatearDistancia(double metros) {
  if (metros < 1000) return '${metros.round()} m';
  return '${(metros / 1000).toStringAsFixed(1)} km';
}
