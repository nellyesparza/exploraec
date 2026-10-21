import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/places_controller.dart';
import '../models/place.dart';

/// Formulario "Agregar lugar": valida y agrega un [Place] — Sesión 2.
/// Desde la Sesión 4, el nuevo lugar se agrega vía `PlacesController`
/// (`Get.find`) en vez de mutar `lugaresEjemplo` directamente y recargar a
/// mano al volver: Inicio (y, más adelante, el Mapa) lo muestran de
/// inmediato. Persistencia real (que sobreviva reiniciar la app) llega en
/// la Sesión 7.
class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _descripcionController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _categoriaController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar lugar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                    labelText: 'Nombre del lugar',
                    hintText: 'Ej. Parque El Ejido'),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'El nombre es obligatorio'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoriaController,
                decoration: const InputDecoration(
                    labelText: 'Categoría', hintText: 'Ej. Cafeterías'),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'La categoría es obligatoria'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
                validator: (valor) =>
                    (valor == null || valor.trim().length < 10)
                        ? 'Escribe al menos 10 caracteres'
                        : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Get.find<PlacesController>().agregarLugar(Place(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      nombre: _nombreController.text.trim(),
                      categoria: _categoriaController.text.trim(),
                      descripcion: _descripcionController.text.trim(),
                      lat: -0.1807,
                      lng: -78.4859,
                    ));
                    Get.back();
                    Get.snackbar('Lugar agregado', 'Ya aparece en Inicio');
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
