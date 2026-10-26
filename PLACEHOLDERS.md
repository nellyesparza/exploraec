# Placeholders de esta rama (sesion-08)

Punto de partida: ExploraEC con «Gastos del viaje» de las Sesiones 6-7 (lista contra el backend, caché de Hive, favoritos persistentes). Tráela con:

```bash
git fetch starter
git checkout starter/sesion-08 -- lib test pubspec.yaml PLACEHOLDERS.md
flutter pub get
```

El objetivo de esta sesión es reemplazar el cliente `http` por `dio` con interceptores, guardar el token en el almacenamiento seguro, manejar la sesión con `AuthController` y completar el CRUD de gastos.

**Todos los bloques son solo de descomentar**: no hay nada que borrar ni que copiar. Cada bloque tiene, justo arriba de su línea `TODO(sesion-08) Paso N`, un comentario `// Por qué:`. Para activarlo, selecciona las líneas comentadas que están debajo del `TODO` (no el `TODO` ni el «Por qué») y presiona `Ctrl + /` (`Cmd + /` en Mac).

## Archivos ya completos (sin `TODO`)
- `lib/services/api_exception.dart` — traduce un error de `dio` a un mensaje legible (`detail` como texto o como lista, sin conexión, tiempo agotado).
- `lib/services/api_client.dart` — `dio` con la dirección del backend (`--dart-define=API_BASE_URL=...`) y tiempo máximo de 15 s. Los dos interceptores están comentados (Pasos 2 y 7).
- `lib/services/secure_token_storage.dart` — leer, guardar y borrar el token con `flutter_secure_storage`.
- `lib/services/gastos_api_service.dart` — las llamadas HTTP de gastos y categorías sobre `ApiClient`.
- `lib/models/usuario.dart`, `lib/utils/validadores.dart`, `lib/widgets/sin_sesion_view.dart`, `lib/screens/login_screen.dart`, `lib/screens/gasto_form_screen.dart`, `lib/screens/cambiar_password_screen.dart`.
- `lib/repositories/gastos_repository.dart` — el de la Sesión 7, con un arreglo: no lee la caja si un 401 la cerró en medio de la lectura.
- `lib/main.dart` — crea `ApiClient` y `AuthController` antes de `runApp`.
- `pubspec.yaml` — suma `dio` y `flutter_secure_storage`; quita `http`.

## Qué descomentar

| Archivo | Bloque | Paso |
|---|---|---|
| `lib/services/api_client.dart` | Interceptor del token (cabecera `Authorization`) | 2 |
| `lib/controllers/auth_controller.dart` | `iniciarSesion` | 2 |
| `lib/screens/gastos_screen.dart` | Pantalla «sin sesión» (`SinSesionView`) | 2 |
| `lib/controllers/auth_controller.dart` | `registrar` | 3 |
| `lib/screens/register_screen.dart` | Validadores de correo y contraseña (2 líneas) | 3 |
| `lib/controllers/auth_controller.dart` | `restaurarSesion` | 4 |
| `lib/controllers/gastos_controller.dart` | `cargarCategorias` y `crear` | 5 |
| `lib/screens/gastos_screen.dart` | Botón «+» | 5 |
| `lib/controllers/gastos_controller.dart` | `actualizar` y `eliminar` | 6 |
| `lib/screens/gastos_screen.dart` | Tocar para editar y botón de eliminar | 6 |
| `lib/services/api_client.dart` | Interceptor del 401 | 7 |
| `lib/controllers/auth_controller.dart` | Limpiar los gastos en `cerrarSesion` | 8 |
| `lib/controllers/auth_controller.dart`, `lib/screens/gastos_screen.dart` | `cambiarPassword` y opción del menú (3 bloques) | 9 (opcional) |

## Pruebas

`test/sesion_08_test.dart` prueba el controller con un servidor falso (no necesita el backend ni el emulador). Con la rama recién traída **fallan las 15**; al terminar cada paso pasan más:

| Después del Paso | Pasan | Fallan |
|---|---|---|
| 1 (rama recién traída) | 0 | 15 |
| 2 | 3 | 12 |
| 3 | 5 | 10 |
| 4 | 7 | 8 |
| 5 | 10 | 5 |
| 6 | 13 | 2 |
| 7 | 14 | 1 |
| 8 | 15 | 0 |

Ejecutarlas: `flutter test`.
