import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings/places_binding.dart';
// TODO(sesion-04): OPCIONAL — descomenta la línea de abajo (Paso 6B — idioma). No borres nada.
// Por qué: el diccionario de textos vive en su propio archivo; sin este import, `AppTranslations` no existe aquí.
import 'i18n/app_translations.dart';
import 'screens/home_screen.dart';
import 'screens/map_placeholder_screen.dart';
import 'screens/favorites_placeholder_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ExploraEcApp());
}

/// `MaterialApp` → `GetMaterialApp` — Sesión 4. Sigue siendo Material por
/// debajo (mismo `theme`, mismos widgets); `GetMaterialApp` agrega encima
/// la navegación de GetX (`Get.to`, usada desde esta sesión en `PlaceCard`
/// y `AddPlaceScreen`) y `initialBinding`, que registra `PlacesController`
/// una sola vez, antes de que cualquier pantalla lo necesite.
class ExploraEcApp extends StatelessWidget {
  const ExploraEcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ExploraEC',
      theme: AppTheme.theme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      // TODO(sesion-04): OPCIONAL — descomenta las tres líneas de abajo (Paso 6B — idioma). No borres nada.
      // Por qué: `translations` le da a GetX el diccionario de textos,
      // `locale` elige el idioma con el que arranca y `fallbackLocale` el
      // que se usa si falta una clave. Con esto, `'clave'.tr` ya funciona.
      translations: AppTranslations(),
      locale: const Locale('es', 'EC'),
      fallbackLocale: const Locale('es', 'EC'),
      initialBinding: PlacesBinding(),
      home: const RootShell(),
    );
  }
}

/// Contenedor raíz con la barra de navegación inferior — Sesión 2.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _indiceActual = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: switch (_indiceActual) {
        0 => const HomeScreen(),
        1 => const MapPlaceholderScreen(),
        _ => const FavoritesPlaceholderScreen(),
      },
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (i) => setState(() => _indiceActual = i),
        // TODO(sesion-04): OPCIONAL — borra el bloque `items: const [...]` de abajo y descomenta el bloque completo. (Paso 6B — idioma)
        // Por qué: `.tr` no es una constante (depende del idioma activo), por
        // eso el `const` desaparece de la lista y de cada ícono que sigue
        // siéndolo. Los textos fijos de abajo nunca cambiarían de idioma.

        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home), label: 'inicio'.tr),
          BottomNavigationBarItem(
              icon: const Icon(Icons.map), label: 'mapa'.tr),
          BottomNavigationBarItem(
              icon: const Icon(Icons.favorite), label: 'favoritos'.tr),
        ],
      ),
    );
  }
}
