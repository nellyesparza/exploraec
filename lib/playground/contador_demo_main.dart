// ExploraEC — Sesión 2: punto de entrada alternativo, solo para practicar
// ContadorDemo sin tocar lib/main.dart (que sigue siendo ExploraEC).
// Ejecutar con: flutter run -t lib/playground/contador_demo_main.dart

import 'package:flutter/material.dart';
import 'contador_demo.dart';

void main() {
  runApp(const MaterialApp(home: ContadorDemo()));
}
