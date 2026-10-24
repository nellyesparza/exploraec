/// Error de red o HTTP ya traducido a un mensaje legible — Sesión 6.
/// `statusCode` es null cuando el fallo no vino de una respuesta HTTP
/// (sin conexión, tiempo agotado).
class ApiException implements Exception {
  final String mensaje;
  final int? statusCode;
  ApiException(this.mensaje, {this.statusCode});

  @override
  String toString() => mensaje;
}
