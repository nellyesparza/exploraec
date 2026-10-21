# Placeholders de esta rama (sesion-05)

Punto de partida: ExploraEC con `PlacesController` (GetX) ya resuelto en Inicio (Sesión 4) y la pestaña Mapa todavía como placeholder. Tráela con:

```bash
git fetch starter
git checkout starter/sesion-05 -- lib pubspec.yaml PLACEHOLDERS.md
```

El objetivo de esta sesión es reemplazar la pestaña "Mapa" (que hasta ahora solo mostraba un texto de aviso) por un mapa real con la posición del usuario y marcadores de los lugares que expone el controller. Cada bloque comentado trae, justo debajo del `TODO`, un comentario `// Por qué:` con la explicación.

## Archivos nuevos ya completos (sin `TODO`)
- `lib/services/location_service.dart` — salvo el bloque de solicitud de permiso, ver tabla abajo.
- `lib/controllers/places_controller.dart` — ya extendido con `posicion`, `estadoPosicion`, `mensajeErrorPosicion`, `cargarPosicion()` y `distanciaA()`.
- `lib/screens/map_screen.dart` — lee el controller con `Obx`; salvo la capa de marcadores, ver tabla abajo.
- `lib/screens/detail_screen.dart` — ya acepta `distanciaMetros` opcional (se usa desde el Paso 4).
- Favoritos en memoria e idioma español/inglés (`lib/i18n/app_translations.dart`) — resultado del Paso 6 opcional de la Sesión 4, ya resuelto en esta rama: el corazón de `PlaceCard` marca favoritos y el botón de idioma de Inicio cambia la barra inferior y el menú "⋮".
- `pubspec.yaml` — ya incluye `geolocator`, `permission_handler`, `flutter_map`, `latlong2`.

## Qué descomentar

| Archivo | Qué descomentar | Paso de la práctica |
|---|---|---|
| `lib/services/location_service.dart` | El bloque `Geolocator.checkPermission()`/`requestPermission()` dentro de `obtenerPosicionActual()` | Paso 3 |
| `lib/screens/map_screen.dart` | El `MarkerLayer` completo (tu posición + un marcador por cada lugar del controller, con navegación al Detalle mostrando la distancia) | Paso 4 |
| `lib/screens/map_screen.dart` | *(Opcional)* El `floatingActionButton` «Centrar en mi ubicación» (usa el `mapController` ya conectado; no hay nada que borrar) | Paso 7A |
| `lib/widgets/place_card.dart` | *(Opcional)* El `import` de `location_service.dart` y el `Obx` con la distancia bajo la categoría (no hay nada que borrar) | Paso 7B |

Los bloques `TODO(sesion-05): OPCIONAL` no cuentan dentro de los 55 minutos: son para quien termina antes. Con la rama recién traída la app compila y corre igual sin ellos.

## Edición manual fuera de este repo (no versionada aquí)

`android/` e `ios/` nunca viven en este repo (ver `README.md`) — los generó `flutter create` una sola vez en la Sesión 1 y no se vuelven a tocar con `git checkout`. Los permisos nativos de esta sesión se agregan **directamente en tu propio proyecto** `exploraec`, a mano:

**Android** — agregar dentro de `android/app/src/main/AndroidManifest.xml`, como hijo directo de `<manifest>` (antes de `<application>`):
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**iOS** — agregar dentro de `ios/Runner/Info.plist`, como un par `<key>`/`<string>` más dentro del `<dict>` principal:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>ExploraEC necesita tu ubicación para mostrarte lugares cercanos.</string>
```

Ninguno de los dos cambios se ve reflejado con hot reload/hot restart — requieren detener `flutter run` por completo y volver a ejecutarlo, porque cambian configuración nativa que la app lee solo al iniciar el proceso.

## Comando de arranque

```bash
flutter pub get
flutter run
```

Con la rama recién traída (antes de descomentar nada), la pestaña Mapa pide el permiso pero nunca lo solicita de verdad (`permiso` queda fijo en `denied`), así que siempre muestra el error de permiso denegado — es el comportamiento esperado hasta completar el Paso 3. Inicio sigue funcionando con los lugares de ejemplo.
