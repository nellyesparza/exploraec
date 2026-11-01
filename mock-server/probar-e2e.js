// Prueba de extremo a extremo — Sesión 9 (Paso 8).
//
// Recorre la cadena completa, sin la app:  tú → backend (login) → MCP del backend → proxy → IA.
//
// Uso (con el backend y el proxy encendidos):
//   node probar-e2e.js <correo> <contraseña>
//
// Direcciones por defecto (cámbialas solo si tus puertos son otros):
//   BACKEND_URL=http://localhost:8000   PROXY_URL=http://localhost:3000   MCP_URL=http://localhost:8000/mcp/
//
// Sin dependencias externas: Node.js 18 o superior.

const { listarHerramientas, llamarHerramienta, MCP_URL } = require('./mcp-cliente');

const BACKEND_URL = (process.env.BACKEND_URL || 'http://localhost:8000').replace(/\/$/, '');
const PROXY_URL = (process.env.PROXY_URL || 'http://localhost:3000').replace(/\/$/, '');
const [correo, clave] = process.argv.slice(2);

let fallos = 0;
const ok = (texto) => console.log(`✅ ${texto}`);
const mal = (texto, ayuda) => {
  fallos += 1;
  console.log(`❌ ${texto}`);
  if (ayuda) console.log(`   → ${ayuda}`);
};

async function main() {
  if (!correo || !clave) {
    console.log('Uso: node probar-e2e.js <correo> <contraseña>');
    console.log('Usa el correo y la contraseña con los que inicias sesión en la app.');
    process.exit(2);
  }

  // 1) El backend responde.
  try {
    const r = await fetch(`${BACKEND_URL}/health`, { signal: AbortSignal.timeout(5000) });
    const datos = await r.json();
    if (r.ok && datos.status === 'ok') ok(`1/4 Backend encendido (${BACKEND_URL}/health)`);
    else mal('1/4 El backend respondió pero no está sano', 'Revisa la terminal A (docker compose up).');
  } catch (_) {
    mal('1/4 No se pudo conectar con el backend', 'Enciende el backend con «docker compose up» (terminal A).');
    return; // sin backend no tiene sentido seguir
  }

  // 2) Inicio de sesión: se obtiene el token (el mismo que usa la app).
  let autorizacion;
  try {
    const r = await fetch(`${BACKEND_URL}/usuarios/token`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({ username: correo, password: clave }),
      signal: AbortSignal.timeout(10000),
    });
    const datos = await r.json();
    if (!r.ok || !datos.access_token) throw new Error('credenciales');
    autorizacion = `Bearer ${datos.access_token}`;
    ok('2/4 Inicio de sesión correcto (token obtenido; no se imprime)');
  } catch (_) {
    mal('2/4 No se pudo iniciar sesión', 'Revisa el correo y la contraseña: son los de tu usuario en la app.');
    return;
  }

  // 3) El servidor MCP del backend publica herramientas y devuelve tu resumen.
  try {
    const nombres = await listarHerramientas(autorizacion);
    if (!nombres.includes('resumen_gastos')) throw new Error('falta resumen_gastos');
    const resumen = await llamarHerramienta('resumen_gastos', {}, autorizacion);
    if (!Array.isArray(resumen.categorias) || resumen.categorias.length !== 4) throw new Error('resumen inesperado');
    ok(`3/4 MCP del backend (${MCP_URL}): ${nombres.length} herramientas; resumen_gastos devolvió ${resumen.categorias.length} categorías, total ${resumen.total_general}`);
  } catch (e) {
    mal(`3/4 El servidor MCP del backend no respondió bien (${e.message})`, `Comprueba que ${MCP_URL} es la dirección del backend de gastos.`);
    return;
  }

  // 4) El proxy: se le manda un resumen VACÍO a propósito. Si responde con origen «mcp», fue el proxy
  //    quien pidió tus datos reales al backend (y no se fio de lo que mandó el «cliente»).
  try {
    const r = await fetch(`${PROXY_URL}/asistente`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Authorization: autorizacion },
      body: JSON.stringify({ consulta: '¿En qué categoría gasto más?', resumen: { categorias: [], total_general: 0 } }),
      signal: AbortSignal.timeout(30000),
    });
    const datos = await r.json();
    if (!r.ok) {
      mal(`4/4 El proxy respondió ${r.status}: ${datos.detail || 'sin detalle'}`,
        r.status === 429 ? 'Se agotó la cuota gratuita: reinicia el proxy sin GEMINI_API_KEY (modo reglas) y repite.' : 'Revisa la terminal D.');
      return;
    }
    const origen = r.headers.get('x-resumen-origen');
    if (origen !== 'mcp') {
      mal('4/4 El proxy usó el resumen que mandó la app (vacío), no el del backend',
        'Falta descomentar el bloque «TODO(sesion-09) Paso 8» en mock-server.js y reiniciar el proxy.');
    } else if (typeof datos.respuesta !== 'string' || datos.respuesta.trim() === '') {
      mal('4/4 El proxy usó el MCP, pero la respuesta llegó vacía', 'Revisa la terminal D.');
    } else {
      ok('4/4 El proxy obtuvo tu resumen del backend por MCP y la IA respondió:');
      console.log(`   «${datos.respuesta}»`);
    }
  } catch (_) {
    mal('4/4 No se pudo conectar con el proxy', 'Enciéndelo con «node mock-server.js» (terminal D).');
  }
}

main().then(() => {
  console.log(fallos === 0 ? '\nTodo bien: la cadena completa funciona.' : `\n${fallos} paso(s) con problemas.`);
  process.exit(fallos === 0 ? 0 : 1);
});
