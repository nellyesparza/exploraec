# Placeholders de esta rama (sesion-10)

Punto de partida: ExploraEC con la Sesión 9 resuelta (Asistente ExploraIA con proxy, confirmación humana, resumen pedido al backend por MCP y preguntas sugeridas). Tráela con:

```bash
git fetch starter
git checkout starter/sesion-10 -- lib test pubspec.yaml PLACEHOLDERS.md docs .github .claude AGENTS.md CLAUDE.md analysis_options.yaml
flutter pub get
```

El objetivo de esta sesión es el **cierre de calidad y entrega continua** de ExploraEC: capturar los errores que nadie esperaba, probar con pruebas de widgets, auditar secretos, poner una **puerta de calidad (CI) en GitHub Actions**, trabajar con un **agente de código dentro de un arnés** (archivo de contexto, permisos, modo plan) y publicar el APK con un **release automático (CD)**. Su único paquete nuevo es `flutter_localizations`, que viene con el SDK de Flutter (textos del sistema en español); la funcionalidad nueva (filtrar los gastos por categoría) la escribe el agente en la práctica.

El **Paso 4** te pide agregar a tu `.gitignore` tres líneas (`.env`, `.claude/settings.local.json` y `CLAUDE.local.md`); por eso el `.gitignore` no se copia desde la rama.

**Los bloques de código son solo de descomentar**: nada que borrar ni copiar. Selecciona las líneas comentadas que están **debajo** de `TODO(sesion-10) Paso N` (no el `TODO` ni el «Por qué») y presiona `Ctrl + /` (`Cmd + /` en Mac). Los pasos del agente (Paso 7) son texto que se le pide a la herramienta.

## Archivos ya completos (sin `TODO`)
- `lib/widgets/error_pantalla_view.dart` — la vista amistosa que reemplaza a la pantalla roja.
- `lib/screens/pantalla_con_fallo.dart` — pantalla que falla a propósito (solo práctica).
- `lib/screens/gastos_screen.dart` — el menú «⋮» suma, solo en modo depuración, «Provocar error de pantalla» y «Provocar error asíncrono».
- `lib/main.dart` — llama a `ReporteErrores.instalar()` antes de `runApp`.
- `.github/workflows/ci.yml` — **CI**: en cada push y pull request analiza el código y ejecuta las pruebas.
- `.github/workflows/release-apk.yml` — **CD**: al subir una etiqueta `v*` verifica, compila el APK y lo publica en un Release.
- `AGENTS.md` — archivo de contexto del proyecto, común a Claude Code, Codex y Antigravity. Trae una sección «Reglas del estudiante» **para completar en el Paso 6**.
- `CLAUDE.md` — importa `AGENTS.md` para Claude Code (que solo lee `AGENTS.md` por sí mismo cuando no existe `CLAUDE.md`).
- `.claude/settings.json` — permisos de ejemplo para Claude Code (puede correr `flutter analyze`/`flutter test`; no puede leer `.env`, hacer `git push` ni crear etiquetas).
- `analysis_options.yaml` — el mismo archivo de `flutter create` con una línea más: excluye `lib/playground/` (los ejercicios de la Sesión 1, que usan `print` a propósito) para que `flutter analyze` no marque avisos que no son de la app.
- `docs/arnes-paso-a-paso.md` — tabla de equivalencias entre Claude Code, Codex y Antigravity, y el hook opcional (Paso 11).
- `docs/README-plantilla.md` y `docs/lista-de-verificacion.md` — plantilla de `README.md` y la rúbrica del Proyecto Final convertida en preguntas.

## Qué descomentar

| Archivo | Bloque | Paso |
|---|---|---|
| `lib/utils/reporte_errores.dart` | `instalar()`: capturar errores no controlados | 2 |
| `test/sesion_10_test.dart` | Tres pruebas de widgets | 3 |
| `lib/screens/gastos_screen.dart` | Opción «Acerca de» y la línea que abre las licencias (2 bloques) | 10 (opcional) |
| `.claude/settings.json` | Un bloque `hooks` que formatea tras cada edición del agente (se agrega a mano desde `docs/arnes-paso-a-paso.md`) | 11 (opcional) |

Los Pasos 5 (CI), 6 (arnés), 7 (código con el agente), 8 (entrega continua) y 9 (APK) no tienen bloques por descomentar: usan los archivos de arriba, Git y GitHub.

## Pruebas

`test/sesion_10_test.dart` usa un servidor falso. Junto con las 22 de las Sesiones 8 y 9 suman 25 con la rama recién traída; al terminar cada paso:

| Después del Paso | Pasan | Fallan |
|---|---|---|
| 1 (rama recién traída) | 24 | 1 |
| 2 | 25 | 0 |
| 3 | 28 | 0 |
| 7 (el agente agrega al menos una prueba) | 29 o más | 0 |

Ejecutarlas: `flutter test`.
