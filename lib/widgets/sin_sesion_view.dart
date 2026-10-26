import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../screens/login_screen.dart';
import '../theme/app_theme.dart';

/// Lo que ve la sección Gastos cuando no hay sesión — Sesión 8. Mientras se
/// comprueba el token guardado muestra un indicador; después, el motivo (si
/// lo hay) y el botón para iniciar sesión.
class SinSesionView extends StatelessWidget {
  const SinSesionView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: Text('gastos'.tr)),
      body: Obx(() {
        if (auth.restaurando.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 56, color: Theme.of(context).colorScheme.outline),
                const SizedBox(height: AppSpacing.md),
                const Text('Inicia sesión para ver los gastos de tu viaje.', textAlign: TextAlign.center),
                if (auth.avisoSesion.value.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(auth.avisoSesion.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () => Get.to(() => const LoginScreen()),
                  child: const Text('Iniciar sesión'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
