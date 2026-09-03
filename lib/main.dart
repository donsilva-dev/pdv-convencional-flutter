import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import 'bindings/pdv_binding.dart';
import 'models/pdv_config.dart';
import 'screens/home_screen.dart';
import 'services/pdv_config_service.dart';
import 'services/vmix_config_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // FULLSCREEN - WINDOWS / LINUX
  // ============================================================

  // if (Platform.isWindows || Platform.isLinux) {
  //   await windowManager.ensureInitialized();

  //   const windowOptions = WindowOptions(
  //     fullScreen: false,
  //     center: true,
  //     backgroundColor: Colors.black,
  //     titleBarStyle: TitleBarStyle.hidden,
  //   );

  //   await windowManager.waitUntilReadyToShow(windowOptions, () async {
  //     await windowManager.setFullScreen(false);
  //     await windowManager.show();
  //     await windowManager.focus();
  //   });
  // }

  // ============================================================
  // PARÂMETROS DO PDV
  // ============================================================

  final configService = PdvConfigService();

  final PdvConfig config = await configService.carregarConfig();

  // ============================================================
  // COMPONENTE DO PDV
  //
  // PRIORIDADE:
  // 1 - GRUPO
  // 2 - NUMEROCOMPONENTE
  // 3 - 0
  // ============================================================

  final vmixConfigService = VmixConfigService();

  final componente = vmixConfigService.carregarComponente();

  print('======================================');
  print('COMPONENTE ATIVO DO PDV: $componente');
  print('======================================');

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => PdvApp(config: config, componente: componente),
    ),
  );
}

class PdvApp extends StatelessWidget {
  final PdvConfig config;
  final int componente;

  const PdvApp({super.key, required this.config, required this.componente});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDV Convencional',
      initialBinding: PdvBinding(config: config, componente: componente),
      home: const HomeScreen(),
    );
  }
}
