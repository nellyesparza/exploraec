# Placeholders de esta rama (sesion-09)

Punto de partida: ExploraEC con la Sesión 8 resuelta (inicio de sesión con token seguro, `ApiClient` con interceptores, CRUD de gastos, cierre de sesión limpio y cambio de contraseña). Tráela con:

```bash
git fetch starter
git checkout starter/sesion-09 -- lib test pubspec.yaml PLACEHOLDERS.md mock-server
flutter pub get
```

El objetivo de esta sesión es el Asistente ExploraIA: una pestaña donde la persona pregunta por sus gastos, conectada a un **proxy** local (`mock-server/`), que llama a Gemini con una clave gratuita guardada solo en la variable de entorno `GEMINI_API_KEY` (o responde con reglas si no hay clave), enviando solo el resumen por categoría y pidiendo confirmación antes de registrar nada.

**Todos los bloques son solo de descomentar**: nada que borrar ni copiar. Selecciona las líneas comentadas que están **debajo** de `TODO(sesion-09) Paso N` (no el `TODO` ni el «Por qué») y presiona `Ctrl + /` (`Cmd + /` en Mac).

## Archivos ya completos (sin `TODO`)
- `mock-server/mock-server.js` — el proxy (Node 18 o superior, sin dependencias): `POST /asistente`. Con `GEMINI_API_KEY` en el entorno llama a Gemini (modelo `gemini-3.5-flash-lite`, cambiable con `GEMINI_MODEL`) y valida su respuesta; sin clave responde con reglas. Traduce 429/502/504 a mensajes legibles. Nunca registra la cabecera `Authorization` ni la clave; solo registra el tamaño y los nombres de los campos que recibe. Trae el bloque del Paso 8 (MCP) ya escrito pero comentado.
- `mock-server/mcp-cliente.js` — cliente MCP mínimo, sin dependencias: abre una sesión en el servidor MCP del backend (`MCP_URL`, por defecto `http://localhost:8000/mcp/`) con el token de la persona y llama a `resumen_gastos` (solo lectura). Nunca lanza: si falla devuelve `null`. Es una **demo**, no un agente.
- `mock-server/probar-e2e.js` — prueba de extremo a extremo (backend → inicio de sesión → MCP → proxy), con ✅/❌ por paso: `node probar-e2e.js <correo> <contraseña>`.
- `mock-server/README.md` — cómo obtener la clave gratuita, los dos modos, el contrato, los errores y qué reconoce el modo reglas. `ejemplo-consulta.json` y `ejemplo-registro.json` sirven para probar el proxy con `curl`, sin la app.
- `lib/services/ai_assistant_service.dart` — `kAiBackendUrl` (`--dart-define=LLM_BACKEND_URL=...`), `RespuestaIA`, `AccionPropuesta` (validada: una acción incompleta se descarta) y `AiAssistantService.preguntar(consulta, resumen)`, con errores traducidos a mensajes legibles. No lleva ninguna clave de IA.
- `lib/models/resumen_gastos.dart` y `GastosApiService.obtenerResumen()` (`GET /gastos/resumen`) con `GastosController.obtenerResumen()`.
- `lib/screens/assistant_screen.dart` — la pantalla completa; solo faltan los bloques de abajo. Incluye el diálogo de confirmación (`confirmarAccion`).
- `lib/main.dart` — registra `AiAssistantService` y agrega la pestaña «Asistente». `SinSesionView` ahora acepta un título.

## Qué descomentar

| Archivo | Bloque | Paso |
|---|---|---|
| `lib/screens/assistant_screen.dart` | Pedir el resumen, llamar al proxy y mostrar la respuesta (3 líneas) | 4 |
| `lib/screens/assistant_screen.dart` | Pedir confirmación cuando la IA propone una acción (1 línea) | 5 |
| `mock-server/mock-server.js` | Pedir el resumen al backend por MCP con el token de la persona (6 líneas, dentro del manejador de `POST /asistente`) | 8 |
| `lib/screens/assistant_screen.dart` | Preguntas sugeridas (`Wrap` con chips) | 9 (opcional) |

## Pruebas

`test/sesion_09_test.dart` (7 pruebas) usa un backend y un proxy falsos: no necesita el backend, el proxy ni el emulador. Junto con las 15 de la Sesión 8 suman 22. Con la rama recién traída **pasan 19 y fallan 3**; al terminar cada paso:

| Después del Paso | Pasan | Fallan |
|---|---|---|
| 1 (rama recién traída) | 19 | 3 |
| 4 | 20 | 2 |
| 5 | 22 | 0 |

Ejecutarlas: `flutter test`.
