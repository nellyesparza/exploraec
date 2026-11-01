// Cliente MCP mínimo para el proxy — Sesión 9 (DEMO).
//
// Qué hace: se conecta al servidor MCP que el backend de gastos (módulo 2) publica en /mcp,
// con el MISMO token de la persona, y llama a UNA herramienta fija de solo lectura:
// `resumen_gastos`. Así el proxy obtiene el resumen directamente del backend, sin fiarse
// de lo que mande la app.
//
// Qué NO es: un agente. Aquí el programa decide qué herramienta llamar (siempre la misma).
// En un agente real el MODELO elegiría entre varias herramientas (ver la teoría de la sesión).
//
// Sin dependencias externas: Node.js 18 o superior (usa fetch). Habla el protocolo MCP
// (JSON-RPC sobre HTTP, transporte «streamable HTTP») a mano, solo lo imprescindible:
//   1) initialize  2) notifications/initialized  3) tools/call
//
// Regla de seguridad: el token (cabecera Authorization) se reenvía, pero NUNCA se registra.

const MCP_URL = (process.env.MCP_URL || 'http://localhost:8000/mcp/').trim();
const ESPERA_MAX_MS = 10000;
const VERSION_PROTOCOLO = '2025-06-18';

/** Envía un mensaje JSON-RPC y devuelve el JSON de la respuesta (acepta JSON o SSE). */
async function enviar(mensaje, autorizacion, sesion) {
  const cabeceras = {
    'Content-Type': 'application/json',
    Accept: 'application/json, text/event-stream',
    Authorization: autorizacion,
    'MCP-Protocol-Version': VERSION_PROTOCOLO,
  };
  if (sesion) cabeceras['Mcp-Session-Id'] = sesion;

  const r = await fetch(MCP_URL, {
    method: 'POST',
    headers: cabeceras,
    body: JSON.stringify(mensaje),
    signal: AbortSignal.timeout(ESPERA_MAX_MS),
  });
  if (!r.ok) throw new Error(`el servidor MCP respondió ${r.status}`);

  const nuevaSesion = r.headers.get('mcp-session-id') || sesion;
  const texto = await r.text();
  if (!texto.trim()) return { sesion: nuevaSesion, datos: null }; // p. ej. 202 de una notificación

  let cuerpo = texto;
  if ((r.headers.get('content-type') || '').includes('text/event-stream')) {
    // SSE: líneas «data: {...}». Se toma el último mensaje con datos.
    const lineas = texto.split(/\r?\n/).filter((l) => l.startsWith('data:'));
    cuerpo = lineas.length ? lineas[lineas.length - 1].slice(5).trim() : '';
  }
  return { sesion: nuevaSesion, datos: cuerpo ? JSON.parse(cuerpo) : null };
}

/** Abre una sesión MCP (initialize + initialized) y devuelve su identificador. */
async function abrirSesion(autorizacion) {
  const inicio = await enviar({
    jsonrpc: '2.0', id: 1, method: 'initialize',
    params: { protocolVersion: VERSION_PROTOCOLO, capabilities: {}, clientInfo: { name: 'proxy-exploraec', version: '1.0' } },
  }, autorizacion, null);
  if (!inicio.datos || inicio.datos.error) throw new Error('el servidor MCP rechazó initialize');
  await enviar({ jsonrpc: '2.0', method: 'notifications/initialized' }, autorizacion, inicio.sesion);
  return inicio.sesion;
}

/** Lee el resultado de una herramienta: `structuredContent` o, si no, el texto JSON de `content`. */
function extraerResultado(respuesta) {
  const r = respuesta && respuesta.result;
  if (!r) throw new Error('respuesta MCP sin resultado');
  if (r.isError) throw new Error('la herramienta devolvió un error');
  let valor = r.structuredContent;
  if (valor && typeof valor === 'object' && valor.result && !valor.categorias && !valor.error) valor = valor.result;
  if (!valor) {
    const texto = Array.isArray(r.content) ? r.content.map((c) => c.text || '').join('') : '';
    valor = JSON.parse(texto);
  }
  // Las herramientas del backend devuelven {"error": "..."} cuando algo falla.
  if (valor && valor.error) throw new Error(`el backend respondió: ${valor.error}`);
  return valor;
}

/** Llama a una herramienta MCP con una sesión nueva. Lanza si algo falla. */
async function llamarHerramienta(nombre, argumentos, autorizacion) {
  const sesion = await abrirSesion(autorizacion);
  const respuesta = await enviar({
    jsonrpc: '2.0', id: 2, method: 'tools/call', params: { name: nombre, arguments: argumentos || {} },
  }, autorizacion, sesion);
  return extraerResultado(respuesta.datos);
}

/** Lista los nombres de las herramientas que publica el servidor (lo usa la prueba de extremo a extremo). */
async function listarHerramientas(autorizacion) {
  const sesion = await abrirSesion(autorizacion);
  const respuesta = await enviar({ jsonrpc: '2.0', id: 2, method: 'tools/list' }, autorizacion, sesion);
  const herramientas = respuesta.datos && respuesta.datos.result && respuesta.datos.result.tools;
  if (!Array.isArray(herramientas)) throw new Error('respuesta MCP sin lista de herramientas');
  return herramientas.map((h) => h.name);
}

/**
 * Pide al backend el resumen de gastos de la persona dueña del token.
 * NUNCA lanza: si algo falla devuelve null y el proxy sigue con el resumen que envió la app.
 */
async function obtenerResumenPorMcp(autorizacion) {
  if (!autorizacion) return null;
  try {
    const resumen = await llamarHerramienta('resumen_gastos', {}, autorizacion);
    if (!resumen || !Array.isArray(resumen.categorias)) throw new Error('el resumen no tiene el formato esperado');
    return resumen;
  } catch (e) {
    console.log(`MCP no disponible (${e.message}): se usa el resumen que envió la app`);
    return null;
  }
}

module.exports = { obtenerResumenPorMcp, listarHerramientas, llamarHerramienta, MCP_URL };
