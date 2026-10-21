import 'package:flutter/material.dart';

/// Placeholder de la pestaña Favoritos — Sesión 2. Se reemplaza por
/// favoritos persistentes con Hive en la Sesión 7.
class FavoritesPlaceholderScreen extends StatelessWidget {
  const FavoritesPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: const Center(
        child: Text(
          'Próximamente: favoritos (Sesión 7)',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}
