import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Estado de carga reutilizable — Sesión 3.
/// Cualquier pantalla que espera datos (hoy simulados, desde la Sesión 6
/// una llamada HTTP real) muestra este mismo widget mientras espera.
class LoadingView extends StatelessWidget {
  final String mensaje;
  const LoadingView({super.key, this.mensaje = 'Cargando...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: AppSpacing.md),
          Text(mensaje, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
