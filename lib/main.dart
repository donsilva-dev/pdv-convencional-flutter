import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings/pdv_binding.dart';
import 'models/pdv_config.dart';
import 'screens/home_screen.dart';
import 'services/pdv_config_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final configService = PdvConfigService();

  final PdvConfig config = await configService.carregarConfig();

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => PdvApp(config: config),
    ),
  );
}

class PdvApp extends StatelessWidget {
  final PdvConfig config;

  const PdvApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDV Convencional',
      initialBinding: PdvBinding(config: config),
      home: const HomeScreen(),
    );
  }
}
