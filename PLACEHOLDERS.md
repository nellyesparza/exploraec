# Placeholders de esta rama (sesion-07)

Punto de partida: ExploraEC con la sección **Gastos** de la Sesión 6 funcionando (registro → login → lista contra el backend de gastos, con el token solo en memoria) y favoritos que viven solo mientras la app está abierta. Tráela con:

```bash
git fetch starter
git checkout starter/sesion-07 -- lib pubspec.yaml PLACEHOLDERS.md
flutter pub get
```

El objetivo de esta sesión es guardar datos en el dispositivo con Hive: una caché de los gastos (`GastosRepository`, una caja por usuario) y favoritos de lugares que sobreviven reiniciar la app. Cada bloque comentado trae, justo debajo del `TODO`, un comentario `// Por qué:` con la explicación.

## Archivos ya completos (sin `TODO`)
- `lib/repositories/gastos_repository.dart` — nuevo y completo: servidor primero, caché de Hive como respaldo, caja `gastos_<id>` por usuario. Hasta completar el Paso 2 el controller no lo usa para cargar, así que el análisis puede marcar `_repository` como «no usado»: es esperado.
- `lib/main.dart` — ya inicializa Hive (`Hive.initFlutter()` y la caja `favoritos`) antes de `runApp` y usa `FavoritesScreen`. **No** abre ninguna caja de gastos.
- `lib/models/gasto.dart` y `lib/models/place.dart` — ya tienen `toMap()`/`fromMap()` (serialización manual).
- `lib/services/gastos_api_service.dart` — suma `obtenerIdUsuario()` (`GET /usuarios/me`), que da nombre a la caja de cada usuario.
- `lib/controllers/gastos_controller.dart` — ya declara `_repository`, `desdeCache` y `ultimaSincronizacion`, y `entrar(...)` ya abre la caja del usuario tras el login. El flujo de la Sesión 6 (registro → login → listar) viene resuelto.
- `lib/screens/favorites_screen.dart` — completo, reemplaza a `favorites_placeholder_screen.dart` (se eliminó de esta rama).
- `lib/widgets/place_card.dart` — ya muestra el corazón de favorito (`Obx`); no persiste nada hasta completar el Paso 3.
- `lib/services/settings_service.dart` — completo; solo se usa en el Paso 6 opcional (idioma guardado).
- `pubspec.yaml` — ya incluye `hive`, `hive_flutter` y `path_provider`.
- Los bloques opcionales de la Sesión 6 (`TODO(sesion-06): OPCIONAL`, deslizar para actualizar) **no** vienen resueltos en esta rama.

## Qué descomentar

| Archivo | Qué descomentar | Paso de la práctica |
|---|---|---|
| `lib/controllers/gastos_controller.dart` | En `cargarGastos()`: borrar el bloque que llama a `_api.listarGastos(...)` directamente y descomentar el que llama a `_repository.obtenerGastos()` | Paso 2 |
| `lib/screens/gastos_screen.dart` | *(Se escribe a mano, el código está en el instructivo)* el banner «Sin conexión — mostrando tus gastos guardados» con `MaterialBanner` | Paso 2 |
| `lib/controllers/places_controller.dart` | Borrar la versión en memoria de `alternarFavorito` y descomentar el cuerpo real (agrega/quita de `_favoritosBox` y de la lista reactiva `favoritos`) | Paso 3 |
| `lib/controllers/gastos_controller.dart` | En `salir()` (cerrar sesión): borrar el método provisional y descomentar el que además llama a `_repository.vaciar()` | Paso 5 |
| `lib/main.dart` | *(Opcional)* Descomentar el `import` y `await SettingsService.abrir();` (no hay nada que borrar); y en `GetMaterialApp`, borrar `locale: const Locale('es', 'EC'),` y descomentar `locale: SettingsService.idioma,` | Paso 6 (opcional) |
| `lib/screens/home_screen.dart` | *(Opcional)* Descomentar el `import`; y en el botón de idioma, borrar el bloque `onPressed: () { ... },` y descomentar `onPressed: SettingsService.alternarIdioma,` | Paso 6 (opcional) |

Con la rama recién traída (antes de descomentar nada) la app funciona igual que al final de la Sesión 6: sin banner y sin caché; los favoritos responden pero se pierden al cerrar la app.

## Pruebas

`test/gastos_controller_test.dart` prueba el controller con un servidor falso (`MockClient`) y una carpeta temporal de Hive: no necesita el backend. Con la rama recién traída **fallan 3** pruebas (las marcadas «Paso 2» y «Paso 5»: el respaldo en caché y el borrado de la caja aún no están conectados); pasan las 10 al completar esos pasos. Ejecutarlas: `flutter test`.

## Comando de arranque

```bash
flutter pub get
flutter run
```
