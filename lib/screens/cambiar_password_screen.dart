import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import '../utils/validadores.dart';

/// Cambiar la contraseña — Sesión 8, Paso 9 (opcional). Si el servidor
/// acepta el cambio (204, sin cuerpo), `AuthController` cierra la sesión para
/// que la persona entre con la contraseña nueva.
class CambiarPasswordScreen extends StatefulWidget {
  const CambiarPasswordScreen({super.key});

  @override
  State<CambiarPasswordScreen> createState() => _CambiarPasswordScreenState();
}

class _CambiarPasswordScreenState extends State<CambiarPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _actual = TextEditingController();
  final _nueva = TextEditingController();
  final AuthController _auth = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _auth.mensajeError.value = '';
  }

  @override
  void dispose() {
    _actual.dispose();
    _nueva.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;
    await _auth.cambiarPassword(_actual.text, _nueva.text);
    // Si salió bien, `cambiarPassword` cerró la sesión.
    if (!_auth.estaAutenticado) Get.until((ruta) => ruta.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _actual,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña actual', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.isEmpty) ? 'Escribe tu contraseña actual' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _nueva,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Contraseña nueva (8 a 72 caracteres)', border: OutlineInputBorder()),
                validator: Validadores.password,
              ),
              const SizedBox(height: AppSpacing.md),
              Obx(() => _auth.mensajeError.value.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(_auth.mensajeError.value,
                          style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    )),
              Obx(() => FilledButton(
                    onPressed: _auth.cargando.value ? null : _enviar,
                    child: const Text('Cambiar contraseña'),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
