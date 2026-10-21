import 'package:flutter/material.dart';
import '../models/place.dart';

/// Formulario "Agregar lugar": valida y agrega un [Place] a la lista
/// en memoria — Sesión 2. Persistencia real llega en la Sesión 7.
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
              // TODO(sesion-02): borra el bloque de abajo y descomenta el bloque completo.
              // Por qué: TextField no valida nada por sí solo —
              // TextFormField agrega la propiedad validator, que
              // rechaza un nombre vacío antes de que se pueda guardar.
              TextField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
              // TextFormField(
              //   controller: _nombreController,
              //   decoration: const InputDecoration(labelText: 'Nombre del lugar', hintText: 'Ej. Parque El Ejido'),
              //   validator: (valor) => (valor == null || valor.trim().isEmpty) ? 'El nombre es obligatorio' : null,
              // ),
              const SizedBox(height: 12),

              // TODO(sesion-02): borra el bloque de abajo y descomenta el bloque completo.
              // Por qué: mismo patrón que el campo anterior — el
              // validator de categoría evita guardar un lugar sin
              // clasificar.
              TextField(controller: _categoriaController, decoration: const InputDecoration(labelText: 'Categoría')),
              // TextFormField(
              //   controller: _categoriaController,
              //   decoration: const InputDecoration(labelText: 'Categoría', hintText: 'Ej. Cafeterías'),
              //   validator: (valor) => (valor == null || valor.trim().isEmpty) ? 'La categoría es obligatoria' : null,
              // ),
              const SizedBox(height: 12),

              // TODO(sesion-02): borra el bloque de abajo y descomenta el bloque completo.
              // Por qué: el validator exige un mínimo de 10 caracteres,
              // para que la descripción realmente aporte información
              // sobre el lugar, en vez de aceptar cualquier texto corto.
              TextField(controller: _descripcionController, decoration: const InputDecoration(labelText: 'Descripción')),
              // TextFormField(
              //   controller: _descripcionController,
              //   decoration: const InputDecoration(labelText: 'Descripción'),
              //   maxLines: 3,
              //   validator: (valor) =>
              //       (valor == null || valor.trim().length < 10) ? 'Escribe al menos 10 caracteres' : null,
              // ),
              const SizedBox(height: 24),

              // TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo.
              // Por qué: onPressed: null deja el botón deshabilitado
              // (se ve en gris) — el bloque real llama a
              // _formKey.currentState!.validate() y solo agrega el
              // Place si los 3 campos pasaron su validator.
              ElevatedButton(onPressed: null, child: const Text('Guardar')),
              // ElevatedButton(
              //   onPressed: () {
              //     if (_formKey.currentState!.validate()) {
              //       lugaresEjemplo.add(Place(
              //         id: DateTime.now().millisecondsSinceEpoch.toString(),
              //         nombre: _nombreController.text.trim(),
              //         categoria: _categoriaController.text.trim(),
              //         descripcion: _descripcionController.text.trim(),
              //         lat: -0.1807,
              //         lng: -78.4859,
              //       ));
              //       Navigator.pop(context);
              //     }
              //   },
              //   child: const Text('Guardar'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
