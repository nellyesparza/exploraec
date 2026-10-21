/// Modelo de datos de ExploraEC — Sesión 2.
///
/// Por ahora vive únicamente en memoria: [lugaresEjemplo] es una lista
/// escrita a mano. La Sesión 6 la reemplaza por datos reales obtenidos
/// de la Overpass API (OpenStreetMap).
class Place {
  final String id;
  final String nombre;
  final String categoria;
  final String descripcion;
  final double lat;
  final double lng;

  Place({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.lat,
    required this.lng,
  });
}

// TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo.
// Por qué: sin datos de ejemplo no hay nada que dibujar en la lista de
// Inicio (Paso 4) — estos 6 lugares reales de Quito permiten probar
// PlaceCard y ListView.builder antes de conectar una fuente de datos
// real en la Sesión 6.

final List<Place> lugaresEjemplo = [
  Place(
    id: '1',
    nombre: 'Parque El Ejido',
    categoria: 'Parques',
    descripcion:
        'Parque urbano en el centro-norte de Quito, con ferias de arte los fines de semana.',
    lat: -0.2073,
    lng: -78.4900,
  ),
  Place(
    id: '2',
    nombre: 'Café Galletti',
    categoria: 'Cafeterías',
    descripcion:
        'Cafetería de especialidad con opciones de trabajo remoto y buen wifi.',
    lat: -0.1938,
    lng: -78.4869,
  ),
  Place(
    id: '3',
    nombre: 'Museo Casa del Alabado',
    categoria: 'Museos',
    descripcion: 'Museo de arte precolombino en el Centro Histórico de Quito.',
    lat: -0.2201,
    lng: -78.5125,
  ),
  Place(
    id: '4',
    nombre: 'Mercado Central',
    categoria: 'Restaurantes',
    descripcion:
        'Mercado tradicional con puestos de comida típica ecuatoriana.',
    lat: -0.2185,
    lng: -78.5110,
  ),
  Place(
    id: '5',
    nombre: 'Parque La Carolina',
    categoria: 'Parques',
    descripcion:
        'Parque metropolitano con jardín botánico, canchas deportivas y lago para botes.',
    lat: -0.1807,
    lng: -78.4859,
  ),
  Place(
    id: '6',
    nombre: 'Vista Hermosa',
    categoria: 'Restaurantes',
    descripcion:
        'Restaurante con terraza y vista panorámica del Centro Histórico.',
    lat: -0.2199,
    lng: -78.5122,
  ),
];
