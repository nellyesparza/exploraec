import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Estado vacío reutilizable — Sesión 3. Se muestra cuando la carga
/// terminó sin error, pero no hay ningún dato que mostrar.
class EmptyView extends StatelessWidget {
  final String mensaje;
  final IconData icono;
  const EmptyView({super.key, this.mensaje = 'No hay nada por aquí todavía', this.icono = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 56, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: AppSpacing.md),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
