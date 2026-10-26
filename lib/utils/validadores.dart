/// Reglas de los formularios — las mismas que aplica el backend (Sesión 8).
/// Validar en la app evita un viaje inútil al servidor; el servidor sigue
/// siendo quien decide.
class Validadores {
  Validadores._();

  static String? correo(String? valor) {
    final texto = valor?.trim() ?? '';
    final ok = texto.contains('@') && texto.contains('.');
    return ok ? null : 'Escribe un correo válido';
  }

  /// El backend exige de 8 a 72 caracteres.
  static String? password(String? valor) {
    final largo = valor?.length ?? 0;
    return (largo >= 8 && largo <= 72) ? null : 'La contraseña debe tener entre 8 y 72 caracteres';
  }
}
