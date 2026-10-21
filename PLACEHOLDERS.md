# Placeholders de esta rama (sesion-02)

Punto de partida: tu propio proyecto `exploraec` (creado en la Sesión 1 con `flutter create`, con `lib/main.dart` mostrando la pantalla de bienvenida) — ya con el remoto `starter` agregado y esta rama traída con:

```bash
git fetch starter
git checkout starter/sesion-02 -- lib pubspec.yaml PLACEHOLDERS.md
```

Esto reemplaza tu `lib/` y tu `pubspec.yaml` por los de esta rama, sin tocar `android/`/`ios/` (esas carpetas nunca viven en este repo — las generó `flutter create` en la Sesión 1 y no vuelven a tocarse). Cada archivo nuevo trae una versión provisional que ya compila (para que `flutter run` nunca muestre una pantalla en blanco ni un error) y, comentada justo debajo — con un comentario `// Por qué:` explicando qué hace y por qué — la versión real que hay que descomentar en la práctica.

| Archivo | Qué descomentar | Paso de la práctica |
|---|---|---|
| `lib/playground/contador_demo.dart` | El `setState()` real dentro de `_incrementar()` | Paso 3 |
| `lib/models/place.dart` | La lista `lugaresEjemplo` con 6 lugares de ejemplo | Paso 4 |
| `lib/widgets/place_card.dart` | El `child` con el cuerpo visual de la tarjeta (`Row`/`Column`/`Text`) | Paso 5 |
| `lib/screens/home_screen.dart` | El `body` con el `ListView.builder` que recorre `lugaresEjemplo` | Paso 5 |
| `lib/widgets/place_card.dart` | El `onTap` que navega a `DetailScreen` | Paso 6 |
| `lib/screens/add_place_screen.dart` | Los 3 `TextFormField` con su `validator` | Paso 7 |
| `lib/screens/add_place_screen.dart` | El `onPressed` del botón "Guardar" | Paso 7 |
| `lib/main.dart` | El `bottomNavigationBar` con sus 3 ítems | Paso 8 |
| `lib/main.dart` | El `body` que alterna según `_indiceActual` | Paso 8 |

En cada archivo, primero se **borra** el bloque provisional (el que ya está activo) y luego se **descomenta** el bloque de abajo — nunca dejes los dos activos a la vez. El comentario `// Por qué:` justo debajo de cada `TODO` explica qué hace ese bloque y por qué está construido así; léelo antes de descomentar, no solo el código. Atajo del editor para descomentar un bloque seleccionado: `Ctrl+/` en Windows/Linux, `Cmd+/` en Mac.

`lib/screens/detail_screen.dart`, `lib/screens/map_placeholder_screen.dart` y `lib/screens/favorites_placeholder_screen.dart` ya están completos, sin `TODO` — no requieren ningún paso de la práctica.

`lib/playground/contador_demo.dart` y `lib/playground/contador_demo_main.dart` son un widget de práctica aparte (Paso 3) — no forman parte de ExploraEC y nunca se importan desde `lib/main.dart`.

## Comando de arranque

```bash
flutter pub get
flutter run
```

Con la rama recién traída (antes de descomentar nada), la app corre con la pantalla de Inicio mostrando "Cargando lugares...", tarjetas vacías si llegaras a tocar una (no hay lista todavía), un formulario con campos sin validar, y sin barra de navegación inferior — todo intencional, para que cada paso de la práctica produzca un cambio visible.

Para el widget de práctica `ContadorDemo` (Paso 3), se ejecuta con un punto de entrada alternativo, sin tocar `lib/main.dart`:

```bash
flutter run -t lib/playground/contador_demo_main.dart
```
