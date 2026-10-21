import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Estado de error reutilizable — Sesión 3. Incluye un botón de reintentar
/// (`onReintentar`) para que el usuario no quede atrapado sin salida.
class ErrorView extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;
  const ErrorView({super.key, required this.mensaje, required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(mensaje, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
