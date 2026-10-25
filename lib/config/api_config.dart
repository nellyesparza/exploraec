/// Dirección del backend de gastos — Sesión 6. Se define al ejecutar con
/// `--dart-define=API_BASE_URL=...`. El valor por defecto (`10.0.2.2`) es
/// cómo el emulador Android ve el `localhost` de tu computador.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
}
