import '../models/gasto.dart';
import 'api_client.dart';

/// Llamadas HTTP de la sección Gastos — Sesión 6, ahora sobre `ApiClient`
/// (`dio`) en la Sesión 8. No sabe nada de sesión ni de token: de eso se
/// encargan el interceptor y `AuthController`.
class GastosApiService {
  GastosApiService(this._client);

  final ApiClient _client;

  /// GET /usuarios/me — `{id, email}`. La Sesión 7 usa el `id` para dar a la
  /// caja de Hive de cada usuario su propio nombre (`gastos_<id>`).
  Future<int> obtenerIdUsuario() async {
    final r = await _client.get('/usuarios/me');
    final id = r.data is Map ? (r.data as Map)['id'] : null;
    if (id is! int) {
      throw ApiException('Respuesta inesperada del servidor al leer tu perfil.');
    }
    return id;
  }

  /// GET /gastos/?skip=&limit= — el total viene en la cabecera X-Total-Count.
  /// La barra final importa: sin ella el servidor responde 307.
  Future<({List<Gasto> gastos, int total})> listarGastos({int skip = 0, int limit = 20}) async {
    final r = await _client.get('/gastos/', query: {'skip': skip, 'limit': limit});
    final json = r.data;
    if (json is! List) {
      throw ApiException('Respuesta inesperada del servidor al listar gastos.');
    }
    final gastos = json.whereType<Map<String, dynamic>>().map(Gasto.fromJson).toList();
    final total = int.tryParse(r.headers.value('x-total-count') ?? '') ?? gastos.length;
    return (gastos: gastos, total: total);
  }

  /// GET /gastos/categorias — `{categorias: [...], limite_por_categoria: 500.0}`.
  /// Las categorías las define el backend: la app no las escribe a mano.
  Future<({List<String> categorias, double limite})> listarCategorias() async {
    final r = await _client.get('/gastos/categorias');
    final json = r.data;
    if (json is! Map || json['categorias'] is! List) {
      throw ApiException('Respuesta inesperada del servidor al leer las categorías.');
    }
    return (
      categorias: (json['categorias'] as List).map((c) => '$c').toList(),
      limite: (json['limite_por_categoria'] as num?)?.toDouble() ?? 500,
    );
  }

  /// POST /gastos/ — `{descripcion, monto, categoria}` (la fecha es opcional:
  /// si se omite, el servidor usa hoy). Responde 201 con el gasto creado.
  Future<Gasto> crear(Map<String, dynamic> datos) async {
    final r = await _client.post('/gastos/', data: datos);
    return Gasto.fromJson(Map<String, dynamic>.from(r.data as Map));
  }

  /// PATCH /gastos/{id} — solo los campos que cambiaron (sin valores `null`).
  Future<Gasto> actualizar(int id, Map<String, dynamic> cambios) async {
    final r = await _client.patch('/gastos/$id', data: cambios);
    return Gasto.fromJson(Map<String, dynamic>.from(r.data as Map));
  }

  /// DELETE /gastos/{id} — responde 204, sin cuerpo.
  Future<void> eliminar(int id) async {
    await _client.delete('/gastos/$id');
  }
}
