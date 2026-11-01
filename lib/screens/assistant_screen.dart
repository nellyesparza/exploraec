import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/gastos_controller.dart';
import '../services/ai_assistant_service.dart';
import '../services/api_exception.dart';
import '../theme/app_theme.dart';
import '../widgets/sin_sesion_view.dart';

/// Asistente ExploraIA — Sesión 9. La persona pregunta por sus gastos; la app
/// pide el resumen por categoría al backend y se lo envía, junto con la
/// pregunta, al proxy del asistente. Si la respuesta propone una acción
/// (registrar un gasto), la app pide confirmación: la IA propone, la persona
/// decide y el backend valida.
class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _campo = TextEditingController();
  final AuthController _auth = Get.find<AuthController>();
  bool _cargando = false;
  String? _respuesta;
  String? _error;

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  Future<void> _preguntar() async {
    final consulta = _campo.text.trim();
    if (consulta.isEmpty) return;
    setState(() {
      _cargando = true;
      _error = null;
      _respuesta = null;
    });
    try {
      // Por qué: el asistente solo necesita totales, no cada gasto. Se pide el
      // resumen por categoría al backend (con el token de tu sesión) y se envía
      // al proxy junto con la pregunta. La respuesta se muestra en pantalla.
      final resumen = await Get.find<GastosController>().obtenerResumen();
      final r = await Get.find<AiAssistantService>().preguntar(consulta, resumen);
      setState(() => _respuesta = r.respuesta);

      // Por qué: si la IA propone registrar un gasto, la app NO lo hace sola.
      // Muestra un diálogo y solo si la persona acepta se llama al backend.
      if (r.accion != null) await confirmarAccion(r.accion!);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } on AsistenteException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  /// Pregunta «¿Confirmas?» y, solo si la respuesta es sí, crea el gasto. El
  /// backend sigue validando (por ejemplo, el límite de 500 por categoría).
  Future<void> confirmarAccion(AccionPropuesta accion) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Confirmar acción'),
        content: Text(
            'La IA propone registrar: ${accion.descripcion} — ${accion.monto.toStringAsFixed(2)} en ${accion.categoria}. ¿Confirmas?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogo, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(dialogo, true), child: const Text('Registrar')),
        ],
      ),
    );
    if (confirmado != true) return;
    try {
      await Get.find<GastosController>().crear(accion.descripcion, accion.monto, accion.categoria);
      if (mounted) {
        setState(() => _respuesta =
            'Listo: registré «${accion.descripcion}» por ${accion.monto.toStringAsFixed(2)} en ${accion.categoria}.');
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!_auth.estaAutenticado) return SinSesionView(titulo: 'asistente'.tr);
      return _contenido(context);
    });
  }

  Widget _contenido(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('asistente'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colores.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline),
                SizedBox(width: AppSpacing.sm),
                Expanded(child: Text('Sugerencia de IA: verifica antes de decidir.')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _campo,
            maxLines: 2,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _cargando ? null : _preguntar(),
            decoration: const InputDecoration(
              labelText: 'Pregunta sobre tus gastos',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final sugerencia in const ['¿En qué categoría gasto más?', '¿Cuánto me queda en comida?', '¿Qué lugar barato de comida me recomiendas?'])
                ActionChip(
                  label: Text(sugerencia),
                  onPressed: _cargando
                      ? null
                      : () {
                          _campo.text = sugerencia;
                          _preguntar();
                        },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: _cargando ? null : _preguntar,
            icon: _cargando
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome),
            label: const Text('Preguntar'),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_error != null)
            Text(_error!, style: TextStyle(color: colores.error))
          else if (_respuesta != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(_respuesta!),
              ),
            )
          else if (!_cargando)
            Text('Escribe una pregunta sobre tus gastos y toca «Preguntar».',
                style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
