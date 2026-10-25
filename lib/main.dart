import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'bindings/places_binding.dart';
import 'i18n/app_translations.dart';
import 'screens/favorites_screen.dart';
import 'screens/gastos_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
// TODO(sesion-07): OPCIONAL — descomenta la línea de abajo (Paso 6 — idioma guardado). No borres nada./ import 'services/settings_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Hive necesita el motor de Flutter listo antes de pedirle al sistema
  // operativo la carpeta donde guardar sus archivos — por eso `main` ahora
  // es `async` y arranca con `ensureInitialized()` antes que nada más.
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  // Solo la caja de favoritos: la de gastos depende de QUIÉN inicie sesión,
  // así que se abre después, en `GastosRepository.abrirParaUsuario()`.
  await Hive.openBox<Map>('favoritos');
  // TODO(sesion-07): OPCIONAL — descomenta la línea de abajo (Paso 6 — idioma guardado). No borres nada.
  // Por qué: el idioma elegido se guarda en su propia caja de Hive
  // (`ajustes`). Hive solo deja leer una caja que ya está abierta, y
  // `GetMaterialApp` necesita el idioma al construirse, así que la caja
  // se abre aquí, antes de `runApp`, igual que la de arriba.
  // await SettingsService.abrir();

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
      translations: AppTranslations(),
      // TODO(sesion-07): OPCIONAL — borra la línea `locale: const Locale('es', 'EC'),` de abajo y descomenta la siguiente. (Paso 6 — idioma guardado)
      // Por qué: la línea fija siempre arranca en español. La real lee el
      // idioma guardado en Hive (y usa español si nunca se eligió otro).
      locale: const Locale('es', 'EC'),
      // locale: SettingsService.idioma,
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
        1 => const MapScreen(),
        2 => const FavoritesScreen(),
        _ => const GastosScreen(),
      },
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _indiceActual,
        onTap: (i) => setState(() => _indiceActual = i),
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.home), label: 'inicio'.tr),
          BottomNavigationBarItem(
              icon: const Icon(Icons.map), label: 'mapa'.tr),
          BottomNavigationBarItem(
              icon: const Icon(Icons.favorite), label: 'favoritos'.tr),
          BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long), label: 'gastos'.tr),
        ],
      ),
    );
  }
}
