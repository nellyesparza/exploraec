# El arnés de un agente de código: guía rápida por herramienta

Un **agente de código** es un modelo de IA más su **arnés**: el programa que lo rodea y que le da un bucle de trabajo, herramientas (leer y editar archivos, ejecutar comandos), permisos, un archivo de contexto, comandos y *hooks*. Claude Code, Codex y Antigravity son arneses distintos; casi todo lo que sigue funciona igual en los tres.

> Esta tabla se verificó contra la documentación oficial de cada herramienta el 2026-10-12 (y, en Antigravity, también con `agy --help`). Los campos marcados con ⚠️ no se pudieron verificar: revísalos en la herramienta antes de depender de ellos. Las herramientas cambian rápido.

## Equivalencias

| Para… | Claude Code | Codex CLI | Antigravity CLI (`agy`) |
|---|---|---|---|
| Abrirla en tu proyecto | `claude` | `codex` | `agy` |
| Archivo de contexto | `CLAUDE.md` (aquí importa a `AGENTS.md`); si no hay `CLAUDE.md`, lee `AGENTS.md` | `AGENTS.md` | `AGENTS.md` o `GEMINI.md` |
| Ver qué cargó | `/memory` (lista los archivos) y `/context` | `/status` (o pedirle «resume las instrucciones actuales») | ⚠️ sin comando documentado: pregúntale qué reglas del proyecto conoce |
| Crear el archivo de contexto | `/init` | `/init` (genera un `AGENTS.md`) | ⚠️ no documentado |
| Modo plan (explora y propone, no edita) | `Shift + Tab` hasta ver «plan mode on», o abrirla con `claude --permission-mode plan` | `/plan` | `/plan`, o abrirla con `agy --mode plan` |
| Permisos | `/permissions` y el archivo `.claude/settings.json` | `/permissions` (y las opciones `--ask-for-approval` y `--sandbox` al abrirla) | `/permissions` y las listas `allow`, `deny` y `ask` de `~/.gemini/antigravity-cli/settings.json` |
| Ver los cambios que hizo | `git diff` | `/diff` | `git diff` |
| *Hooks* (comandos automáticos) | `.claude/settings.json`; `/hooks` los muestra | `.codex/config.toml`; hay que confiar en cada hook; `/hooks` los gestiona | `/hooks` ⚠️ formato no verificado |
| Servidores MCP | `claude mcp` | `codex mcp` | `agy mcp` |
| Una sola tarea sin interfaz | `claude -p "tarea"` | `codex exec "tarea"` | `agy -p "tarea"` |

**Importante:** Claude Code solo lee `AGENTS.md` por sí mismo cuando **no** existe un `CLAUDE.md`. En este proyecto hay los dos: por eso `CLAUDE.md` empieza con la línea `@AGENTS.md`, que importa el contenido. Así las tres herramientas leen las mismas reglas y las mantienes en un solo archivo.

> **Gemini CLI** ya no es una opción: Google lo reemplazó por Antigravity CLI y, desde el 18 de junio de 2026, las cuentas gratuitas, Pro y Ultra no pueden usarlo. Si lo tenías instalado, usa `agy`.

## Qué trae este proyecto

- `AGENTS.md` — el archivo de contexto (reglas del proyecto, cómo verificar, qué está prohibido).
- `CLAUDE.md` — importa `AGENTS.md` para Claude Code.
- `.claude/settings.json` — permisos para Claude Code: puede ejecutar `flutter analyze`, `flutter test`, `dart format`, `git status` y `git diff` sin preguntar; **no puede** leer `.env`, ni hacer `git push`, ni crear etiquetas.
- `.github/workflows/ci.yml` — la puerta de calidad: analiza y prueba cada cambio en GitHub.

## Paso 11 (opcional): un *hook* que formatea tras cada edición

Un *hook* es un comando que **siempre** se ejecuta en un momento fijo del trabajo del agente; a diferencia de una regla escrita en el archivo de contexto, no depende de que el modelo la recuerde.

En Claude Code, agrega este bloque a `.claude/settings.json` (junto a `permissions`, separado por una coma):

```json
"hooks": {
  "PostToolUse": [
    {
      "matcher": "Edit|Write",
      "hooks": [{ "type": "command", "command": "dart format lib test" }]
    }
  ]
}
```

Después, escribe `/hooks` en Claude Code: debe aparecer el hook bajo `PostToolUse`. Cada vez que el agente edite o cree un archivo, se formatea `lib` y `test`.

En Codex los hooks se declaran en `.codex/config.toml` y se debe confiar en cada uno antes de que corra; revisa la documentación de Codex para el formato exacto.

## Buenas prácticas con cualquier arnés

1. **Plan primero** en cambios que toquen más de un archivo; aprueba el plan antes de dejar que edite.
2. **Cambios pequeños**: una funcionalidad por vez, con su prueba.
3. **Verifica tú, no solo el agente**: corre `flutter analyze` y `flutter test` y mira el `git diff` completo antes de hacer commit.
4. **Cero secretos** en el contexto: ni en el archivo de contexto, ni en los prompts, ni en lo que le pegas.
5. **Tú haces el `git push`**: el CI de GitHub revisa lo que subes, y una persona decide cuándo se publica una versión.
