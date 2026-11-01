/// Resumen de gastos por categoría, tal como lo devuelve `GET /gastos/resumen`
/// — Sesión 9. Es lo ÚNICO que se envía al proxy del asistente: totales por
/// categoría, sin descripciones, fechas ni correo (datos mínimos).
class ResumenCategoria {
  final String categoria;
  final double total;
  final int cantidad;
  final double disponible;

  const ResumenCategoria({
    required this.categoria,
    required this.total,
    required this.cantidad,
    required this.disponible,
  });

  /// Defensivo a propósito: un campo faltante no debe tumbar toda la respuesta.
  factory ResumenCategoria.fromJson(Map<String, dynamic> json) => ResumenCategoria(
        categoria: (json['categoria'] as String?) ?? 'otros',
        total: (json['total'] as num?)?.toDouble() ?? 0,
        cantidad: (json['cantidad'] as num?)?.toInt() ?? 0,
        disponible: (json['disponible'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'categoria': categoria,
        'total': total,
        'cantidad': cantidad,
        'disponible': disponible,
      };
}

class ResumenGastos {
  final List<ResumenCategoria> categorias;
  final double totalGeneral;

  const ResumenGastos({required this.categorias, required this.totalGeneral});

  factory ResumenGastos.fromJson(Map<String, dynamic> json) => ResumenGastos(
        categorias: (json['categorias'] as List? ?? const [])
            .whereType<Map>()
            .map((m) => ResumenCategoria.fromJson(Map<String, dynamic>.from(m)))
            .toList(),
        totalGeneral: (json['total_general'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'categorias': categorias.map((c) => c.toJson()).toList(),
        'total_general': totalGeneral,
      };
}
