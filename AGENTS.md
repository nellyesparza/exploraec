# AGENTS.md — reglas del proyecto ExploraEC

Este archivo lo leen los agentes de código (Claude Code, Codex, Antigravity…) al abrir esta carpeta. Es el **archivo de contexto** del proyecto: lo que un agente nuevo necesita saber para trabajar bien aquí. Se mantiene corto y concreto.

## Qué es el proyecto

ExploraEC es una app Flutter (Android) para explorar lugares de Ecuador y llevar los gastos de un viaje. Estado con GetX, datos remotos con `dio` contra un backend de gastos (FastAPI con JWT), caché local con Hive, token en `flutter_secure_storage` y un asistente de IA que habla con un proxy.

## Dónde está cada cosa

- `lib/controllers/` — estado compartido (controladores GetX).
- `lib/services/` y `lib/repositories/` — acceso al backend y a los datos locales.
- `lib/screens/` y `lib/widgets/` — pantallas y piezas de interfaz.
- `lib/models/`, `lib/utils/` — modelos y utilidades.
- `test/` — pruebas de widgets y de servicios.

## Cómo verificar (siempre, antes de dar un cambio por terminado)

```bash
flutter analyze
flutter test
```

Los dos deben terminar sin errores. Si fallan, corrige el código; no desactives el análisis ni borres pruebas para que pasen.

## Convenciones

- El estado compartido vive en un controlador GetX; las pantallas no llaman directamente al backend ni a Hive.
- Todo texto visible para la persona va en español neutro.
- Cada pantalla con datos cubre los tres estados: cargando, vacío y error.
- Cambios pequeños y enfocados: una funcionalidad a la vez, con una prueba de widget por cada comportamiento nuevo.

## Prohibido

- Escribir claves, tokens o contraseñas en el código, en los registros o en este archivo. No leer ni modificar `.env`.
- Agregar dependencias nuevas sin avisar antes y explicar por qué hacen falta.
- Ejecutar `git push` o crear etiquetas: eso lo hace la persona después de revisar el cambio.

## Reglas del estudiante

<!-- Paso 6 de la práctica: escribe aquí dos reglas propias para ESTE proyecto. -->

- (regla 1)
- (regla 2)
