/// Un gasto del viaje, tal como lo devuelve el backend — Sesión 6. Desde la
/// Sesión 7 también se puede guardar en la caché de Hive con `toMap()` y
/// reconstruir con `Gasto.fromMap()`.
class Gasto {
  final int id;
  final String descripcion;
  final double monto;
  final String categoria;
  final String fecha;

  const Gasto({
    required this.id,
    required this.descripcion,
    required this.monto,
    required this.categoria,
    required this.fecha,
  });

  /// Defensivo a propósito: `monto` puede llegar como entero (`6`) o
  /// decimal (`6.5`), y un campo faltante no debe tumbar toda la lista.
  factory Gasto.fromJson(Map<String, dynamic> json) {
    return Gasto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      descripcion: (json['descripcion'] as String?) ?? 'Sin descripción',
      monto: (json['monto'] as num?)?.toDouble() ?? 0,
      categoria: (json['categoria'] as String?) ?? 'otros',
      fecha: (json['fecha'] as String?) ?? '',
    );
  }

  /// Serialización manual para la caché local — Sesión 7. Los 5 campos son
  /// primitivos, así que no hace falta un `TypeAdapter` generado. Mismos
  /// nombres que el JSON del backend.
  Map<String, dynamic> toMap() => {
        'id': id,
        'descripcion': descripcion,
        'monto': monto,
        'categoria': categoria,
        'fecha': fecha,
      };

  /// Hive devuelve los mapas como `Map<dynamic, dynamic>`: por eso se copian
  /// a `Map<String, dynamic>` antes de leerlos.
  factory Gasto.fromMap(Map mapa) => Gasto.fromJson(Map<String, dynamic>.from(mapa));
}
