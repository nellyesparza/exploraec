import 'package:flutter/material.dart';

/// Widget de práctica de la Sesión 2 — no forma parte de ExploraEC.
/// Sirve para sentir en carne propia `setState`, `initState` y `dispose`
/// antes de aplicarlos en la app real (barra de navegación inferior, Paso 8).
class ContadorDemo extends StatefulWidget {
  const ContadorDemo({super.key});

  @override
  State<ContadorDemo> createState() => _ContadorDemoState();
}

class _ContadorDemoState extends State<ContadorDemo> {
  int _veces = 0;

  @override
  void initState() {
    super.initState();
    // Se ejecuta una sola vez, apenas se crea este State — revisa la
    // terminal donde corre `flutter run` para ver este mensaje una única
    // vez, incluso si tocás el botón muchas veces después.
    print('initState: el contador arrancó en $_veces');
  }

  @override
  void dispose() {
    // Se ejecuta cuando este widget se elimina definitivamente del árbol —
    // el lugar correcto para liberar lo que initState() preparó.
    print('dispose: el contador se cierra en $_veces');
    super.dispose();
  }

  void _incrementar() {
    // TODO(sesion-02): borra la línea de abajo y descomenta el bloque completo. (Paso 3 — setState real)
    // Por qué: sin setState(), _veces sí cambia en memoria (fijate en la
    // terminal) pero Flutter nunca se entera de que debe reconstruir la
    // pantalla — el número en pantalla se queda congelado en 0.
    print('Tocaste +, pero setState() todavía no está activo: el número no cambia en pantalla.');
    // setState(() {
    //   _veces++;
    // });
  }

  @override
  Widget build(BuildContext context) {
    print('build: reconstruyendo con _veces = $_veces');
    return Scaffold(
      appBar: AppBar(title: const Text('ContadorDemo — práctica Sesión 2')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('_veces', style: TextStyle(color: Colors.grey)),
            Text('$_veces', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementar,
        child: const Icon(Icons.add),
      ),
    );
  }
}
