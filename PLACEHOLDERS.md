# Placeholders de esta rama (sesion-03)

Punto de partida: ExploraEC con el catálogo de widgets de la Sesión 2 ya resuelto (modelo `Place`, `PlaceCard`, Inicio/Detalle/Formulario, navegación inferior). Tráela con:

```bash
git fetch starter
git checkout starter/sesion-03 -- lib pubspec.yaml PLACEHOLDERS.md
```

El objetivo de esta sesión es aplicar tema visual de marca, estados de carga/vacío/error, un layout responsivo y una pasada de accesibilidad — sin agregar pantallas nuevas. Cada bloque comentado trae, justo debajo del `TODO`, un comentario `// Por qué:` con la explicación — léelo antes de descomentar.

| Archivo | Qué descomentar | Paso de la práctica |
|---|---|---|
| `lib/main.dart` | `theme: AppTheme.theme` en el `MaterialApp` | Paso 1 |
| `lib/models/place.dart` | El cuerpo real de `fetchLugaresSimulado` (con `Future.delayed` y los parámetros `forzarError`/`forzarVacio`) | Paso 3 |
| `lib/screens/home_screen.dart` | El `body: FutureBuilder<List<Place>>(...)` completo, con `LoadingView`/`ErrorView`/`EmptyView` | Paso 3 |
| `lib/screens/home_screen.dart` | El método `_buildLista` con `LayoutBuilder` (reemplaza la versión simple de `ListView` de arriba por la versión responsiva con `GridView` en pantallas anchas) | Paso 4 |
| `lib/widgets/place_card.dart` | El `Semantics(...)` que envuelve el contenido de la tarjeta | Paso 5 |
| `lib/main.dart` | **Opcional:** `darkTheme: AppTheme.darkTheme,` y `themeMode: ThemeMode.system,` (solo descomentar, no hay nada que borrar). `AppTheme.darkTheme` ya viene completo en `lib/theme/app_theme.dart` | Paso 6 (opcional) |

En cada archivo, primero se **borra** el bloque provisional (el que ya está activo) y luego se **descomenta** el bloque de abajo — nunca dejes los dos activos a la vez. Atajo del editor para descomentar un bloque seleccionado: `Ctrl+/` en Windows/Linux, `Cmd+/` en Mac.

`lib/theme/app_theme.dart` (incluido `darkTheme`), `lib/widgets/loading_view.dart`, `lib/widgets/empty_view.dart` y `lib/widgets/error_view.dart` ya están completos, sin `TODO` — se explican en la teoría y se usan tal cual desde el Paso 1/3.

## Comando de arranque

```bash
flutter pub get
flutter run
```

Con la rama recién clonada (antes de descomentar nada), la app se ve exactamente igual que al final de la Sesión 2: tema por defecto de Flutter, sin estados de carga/error, lista simple sin adaptarse al ancho de pantalla. Cada paso descomentado agrega un cambio visual distinto y verificable — usa el menú "⋮" de la AppBar (Paso 3 en adelante) para simular los 3 estados sin necesitar red.
