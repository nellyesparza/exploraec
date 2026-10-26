import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/gastos_controller.dart';
import '../models/gasto.dart';
import '../services/api_exception.dart';
import '../theme/app_theme.dart';

/// Formulario para crear (`gasto == null`) o editar un gasto — Sesión 8. Las
/// categorías vienen del servidor. Si el servidor rechaza el gasto (por
/// ejemplo, supera el límite de 500), el formulario NO se cierra: muestra el
/// mensaje y conserva lo escrito.
class GastoFormScreen extends StatefulWidget {
  final Gasto? gasto;
  const GastoFormScreen({super.key, this.gasto});

  @override
  State<GastoFormScreen> createState() => _GastoFormScreenState();
}

class _GastoFormScreenState extends State<GastoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final GastosController _gastos = Get.find<GastosController>();
  late final TextEditingController _descripcion;
  late final TextEditingController _monto;
  String? _categoria;
  bool _guardando = false;
  String? _error;

  bool get _esEdicion => widget.gasto != null;

  @override
  void initState() {
    super.initState();
    final g = widget.gasto;
    _descripcion = TextEditingController(text: g?.descripcion ?? '');
    _monto = TextEditingController(text: g == null ? '' : g.monto.toString());
    _categoria = g?.categoria;
  }

  @override
  void dispose() {
    _descripcion.dispose();
    _monto.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final descripcion = _descripcion.text.trim();
    final monto = double.parse(_monto.text.replaceAll(',', '.'));
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      final g = widget.gasto;
      if (g == null) {
        await _gastos.crear(descripcion, monto, _categoria!);
      } else {
        // PATCH: solo viajan los campos que cambiaron.
        final cambios = <String, dynamic>{
          if (descripcion != g.descripcion) 'descripcion': descripcion,
          if (monto != g.monto) 'monto': monto,
          if (_categoria != g.categoria) 'categoria': _categoria,
        };
        if (cambios.isNotEmpty) await _gastos.actualizar(g.id, cambios);
      }
      Get.back();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar gasto' : 'Nuevo gasto')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descripcion,
                maxLength: 200,
                decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Escribe una descripción' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _monto,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Monto', border: OutlineInputBorder()),
                validator: (v) {
                  final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                  return (n == null || n <= 0) ? 'El monto debe ser mayor a 0' : null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Obx(() => DropdownButtonFormField<String>(
                    initialValue: _gastos.categorias.contains(_categoria) ? _categoria : null,
                    decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                    items: [
                      for (final c in _gastos.categorias) DropdownMenuItem(value: c, child: Text(c)),
                    ],
                    onChanged: (v) => setState(() => _categoria = v),
                    validator: (v) => v == null ? 'Elige una categoría' : null,
                  )),
              const SizedBox(height: AppSpacing.md),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              FilledButton(
                onPressed: _guardando ? null : _guardar,
                child: _guardando
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_esEdicion ? 'Guardar cambios' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
