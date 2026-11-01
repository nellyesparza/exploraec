import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Lo que ve la persona cuando una pantalla falla al construirse — Sesión 10.
/// Reemplaza a la pantalla roja de depuración. No usa `Theme` ni `Scaffold`
/// a propósito: puede aparecer en cualquier parte del árbol, incluso fuera de
/// `MaterialApp`, y no debe fallar a su vez. El fondo es claro, así que pide
/// íconos oscuros en la barra de estado (si no, el reloj se vería blanco
/// sobre blanco).
class ErrorPantallaView extends StatelessWidget {
  const ErrorPantallaView({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: ColoredBox(
          color: Color(0xFFF7F9FA),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sentiment_dissatisfied_outlined, size: 56, color: Color(0xFF6B7785)),
                  SizedBox(height: 12),
                  Text(
                    'Esta pantalla tuvo un problema',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Roboto', fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF0E2841), decoration: TextDecoration.none),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Ya lo registramos. Vuelve atrás y prueba de nuevo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: Color(0xFF4A5563), decoration: TextDecoration.none),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
