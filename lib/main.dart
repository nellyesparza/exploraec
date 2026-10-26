import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'bindings/places_binding.dart';
import 'controllers/auth_controller.dart';
import 'i18n/app_translations.dart';
import 'screens/favorites_screen.dart';
import 'screens/gastos_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'services/api_client.dart';
import 'services/settings_service.dart';
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
  // El idioma elegido se guarda en su propia caja de Hive (`ajustes`).
  await SettingsService.abrir();
  // Sesión 8: un solo `ApiClient` (dio) y un solo `AuthController` para toda
  // la app. Al crearse, el controller comprueba si hay un token guardado.
  Get.put(ApiClient(), permanent: true);
  Get.put(AuthController(), permanent: true);
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
      locale: SettingsService.idioma,
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
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'inicio'.tr),
          BottomNavigationBarItem(icon: const Icon(Icons.map), label: 'mapa'.tr),
          BottomNavigationBarItem(icon: const Icon(Icons.favorite), label: 'favoritos'.tr),
          BottomNavigationBarItem(icon: const Icon(Icons.receipt_long), label: 'gastos'.tr),
        ],
      ),
    );
  }
}
