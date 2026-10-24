/// Un gasto del viaje, tal como lo devuelve el backend — Sesión 6.
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
}
