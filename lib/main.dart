import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/game_controller.dart';
import 'views/adventure_page.dart';
import 'views/pluto_home_page.dart';
import 'views/welcome_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final controller = GameController(preferences);
  await controller.restoreSavedGame();
  Get.put(controller);
  runApp(
    MagicKingdomGame(
      initialRoute: controller.hasSavedGame ? '/adventure' : '/',
    ),
  );
}

class MagicKingdomGame extends StatelessWidget {
  const MagicKingdomGame({super.key, this.initialRoute = '/'});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<GameController>()) Get.put(GameController());
    return GetMaterialApp(
      title: '生日專屬迪士尼',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D4DCE)),
        useMaterial3: false,
        fontFamilyFallback: const ['PingFang TC', 'Noto Sans TC'],
      ),
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/', page: () => const WelcomePage()),
        GetPage(name: '/adventure', page: () => const AdventurePage()),
        GetPage(name: '/pluto-home', page: () => const PlutoHomePage()),
      ],
    );
  }
}
