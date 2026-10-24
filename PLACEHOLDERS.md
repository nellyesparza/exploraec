# Placeholders de esta rama (sesion-06)

Punto de partida: ExploraEC con lugares y mapa de las Sesiones 1-5 intactos, más la sección nueva **Gastos**, que habla con el backend de gastos del módulo anterior. Tráela con:

```bash
git fetch starter
git checkout starter/sesion-06 -- lib pubspec.yaml PLACEHOLDERS.md
flutter pub get
```

Los cambios nativos (permiso de internet y tráfico HTTP en claro) se hacen **a mano** en tu proyecto, porque `android/` no vive en este repo (ver `README.md`).

## Qué descomentar

| Archivo | Qué descomentar | Paso de la práctica |
|---|---|---|
| `lib/controllers/gastos_controller.dart` | `entrar(...)` (registro → login → listar) y `cargarGastos()` | Paso 7 |
| `lib/services/gastos_api_service.dart` | Cambiar `.timeout(const Duration(seconds: 15))` por 1 ms y devolverlo a 15 s | Paso 9 |
| `lib/screens/gastos_screen.dart` | *(Opcional)* `RefreshIndicator` (borrar el `return _buildLista(...)` y descomentar el bloque) | Paso 10 |

## Pruebas

`test/gastos_controller_test.dart` prueba el controller con un servidor falso (`MockClient`): no necesita el backend. Con la rama recién traída **fallan** (el flujo del Paso 7 aún es provisional); pasan las 7 cuando completas el Paso 7. Ejecutarlas: `flutter test`.
