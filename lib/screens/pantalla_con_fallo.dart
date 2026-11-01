import 'package:flutter/widgets.dart';

/// Pantalla que falla A PROPÓSITO — Sesión 10 (solo práctica). Se abre desde el
/// menú «⋮» de Gastos, que solo muestra esa opción en modo depuración.
class PantallaConFallo extends StatelessWidget {
  const PantallaConFallo({super.key});

  @override
  Widget build(BuildContext context) {
    throw StateError('Fallo provocado a propósito para la práctica');
  }
}
