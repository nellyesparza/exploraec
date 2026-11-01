# Proxy del asistente ExploraIA

Servidor local de la Sesión 9. **No forma parte de la app Flutter.** Es el único lugar donde vive la clave del proveedor de IA: la app solo conoce la dirección del proxy. (El nombre de la carpeta es histórico: antes el proxy solo respondía con reglas.)

Tiene dos modos, según exista o no la variable de entorno `GEMINI_API_KEY` al encenderlo:

| Modo | Cuándo | Qué hace |
|---|---|---|
| **GEMINI** | Con `GEMINI_API_KEY` definida | Llama al modelo de Google con tu clave gratuita |
| **REGLAS** | Sin clave | Responde con reglas simples, sin internet; sirve para seguir practicando si se agota la cuota del día |

## Obtener la clave gratuita

1. Entra a <https://aistudio.google.com/apikey> con una cuenta personal de Google (se exige mayoría de edad).
2. Pulsa **Create API key** y copia la clave.
3. **No la escribas en ningún archivo del proyecto ni la subas a git.** Se define solo en la terminal del proxy.

El plan gratuito permite pocas consultas al día (los límites exactos se ven en AI Studio) y Google puede usar el contenido de esas consultas para mejorar sus productos: por eso al proxy solo viaja el resumen por categoría.

## Cómo se usa

Linux y Mac:

```bash
cd mock-server
export GEMINI_API_KEY="pega-aquí-tu-clave"
node mock-server.js
```

Windows (PowerShell):

```powershell
cd mock-server
$env:GEMINI_API_KEY="pega-aquí-tu-clave"
node mock-server.js
```

Requiere Node.js 18 o superior. El mensaje inicial indica el modo (`modo GEMINI` o `modo REGLAS`). El modelo por defecto es `gemini-3.5-flash-lite`; se cambia con la variable `GEMINI_MODEL` (por ejemplo, si Google lo retira).

Para pasar al modo reglas, cierra el proxy (`Ctrl + C`), borra la variable y vuelve a encenderlo:

```bash
unset GEMINI_API_KEY
node mock-server.js
```

(En PowerShell: `Remove-Item Env:GEMINI_API_KEY`.)

## Contrato

`POST /asistente`, con la cabecera `Authorization: Bearer <token>`. El proxy **nunca la registra**; solo la reenvía al servidor MCP del backend (ver «Conexión con el MCP del backend», Paso 8).

Petición:

```json
{ "consulta": "¿cuánto me queda en comida?",
  "resumen": { "categorias": [ { "categoria": "comida", "total": 20.0, "cantidad": 2, "disponible": 480.0 } ],
               "total_general": 20.0 } }
```

Respuesta (`accion` es opcional):

```json
{ "respuesta": "Te quedan 480.00 en comida (límite de 500 por categoría).",
  "accion": { "tipo": "registrar_gasto", "descripcion": "Almuerzo", "monto": 6.5, "categoria": "comida" } }
```

Errores (siempre `{ "detail": "mensaje legible" }`, que la app muestra tal cual):

| Código | Cuándo |
|---|---|
| 422 | Falta la consulta o pasa de 500 caracteres |
| 429 | Se agotó la cuota gratuita de la IA |
| 502 | La clave fue rechazada, la IA devolvió algo inesperado o no hay conexión a internet |
| 504 | La IA tardó más de 15 segundos |

En modo GEMINI el proxy valida la respuesta del modelo antes de enviarla: una acción incompleta, de otro tipo o con una categoría inexistente se descarta y solo llega el texto.

## Conexión con el MCP del backend (demo del Paso 8)

El backend de gastos (módulo 2) publica un **servidor MCP** en `/mcp` con 7 herramientas y acepta el mismo token que la app. En el Paso 8 el proxy se conecta a él (`mcp-cliente.js`) y llama a **una sola herramienta de solo lectura**, `resumen_gastos`, con el token de la persona. Así la IA recibe el resumen que da el backend y no el que mande la app.

- Es un **cliente MCP mínimo**, escrito a mano para que se vea el protocolo (`initialize` → `initialized` → `tools/call`). En un proyecto real se usaría el SDK oficial de MCP.
- Es **solo una demo**: el programa decide qué herramienta llamar (siempre la misma). **No es un agente.** En un agente real el modelo elegiría entre varias herramientas.
- **Camino correcto**: el agente vive en el servidor, el modelo solo ve una **lista blanca** de herramientas de **solo lectura**, hay un **tope de iteraciones** y límites de uso, y las acciones que cambian datos vuelven a la app como propuesta para que la persona confirme (como en el Paso 5).
- Si el backend o el MCP no responden, el proxy sigue con el resumen que mandó la app. La respuesta lleva la cabecera `X-Resumen-Origen: mcp` o `app` para saber cuál se usó.
- Variable de entorno `MCP_URL` (por defecto `http://localhost:8000/mcp/`, con la barra final).

### Prueba de extremo a extremo

Con el backend y el proxy encendidos (usa el correo y la contraseña de tu usuario en la app):

```bash
node probar-e2e.js tu-correo@ejemplo.com tu-contraseña
```

Comprueba cuatro cosas, con ✅ o ❌: (1) el backend está sano, (2) el inicio de sesión da un token, (3) el MCP del backend publica `resumen_gastos` y devuelve tus categorías, (4) el proxy, al que se le manda un resumen **vacío** a propósito, responde usando el resumen del backend. Antes de descomentar el Paso 8, el 4 falla con un mensaje que lo explica. Otras direcciones: `BACKEND_URL`, `PROXY_URL` y `MCP_URL`.

## Probar el proxy sin la app

Con el proxy encendido, desde la carpeta raíz del proyecto (en PowerShell usa `curl.exe` en vez de `curl`):

```bash
curl -X POST -H "Content-Type: application/json" -d @mock-server/ejemplo-consulta.json http://localhost:3000/asistente
curl -X POST -H "Content-Type: application/json" -d @mock-server/ejemplo-registro.json http://localhost:3000/asistente
```

## URL de la app

En el emulador Android la app usa por defecto `http://10.0.2.2:3000` (valor de `LLM_BACKEND_URL`); no hay que cambiar nada. El backend de gastos tiene su propia URL (`API_BASE_URL`, puerto 8000).

## Qué reconoce el modo reglas

| Escribes | Responde |
|---|---|
| ¿En qué categoría gasto más? | La categoría con mayor total del resumen |
| ¿Cuánto me queda en comida? | El campo `disponible` de esa categoría |
| Registra un almuerzo de 6.50 en comida | Propone una `accion` (la app pide confirmación antes de crear nada) |
| ¿Qué lugar barato de comida me recomiendas? | Una respuesta genérica |
| Cualquier otra cosa | «No entendí tu pregunta…» |

## Seguridad

- La clave solo se lee de la variable de entorno; el proxy nunca la imprime ni la guarda, y viaja en una cabecera (no en la URL) hacia Google.
- El registro del proxy muestra el tamaño y los **nombres** de los campos recibidos, nunca su contenido ni el token.
- Si una clave se filtra, se crea otra en AI Studio y se desactiva la anterior.
