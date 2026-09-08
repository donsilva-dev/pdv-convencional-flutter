import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import 'bindings/pdv_binding.dart';
import 'models/app_config.dart';
import 'models/pdv_config.dart';
import 'screens/home_screen.dart';
import 'services/app_config_service.dart';
import 'services/pdv_config_service.dart';
import 'services/pdv_log_service.dart';
import 'services/vmix_config_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // LOG DO FRONTEND
  // ============================================================

  final logService = PdvLogService();

  await logService.inicializar();

  // ============================================================
  // CONFIGURAÇÃO DO FRONTEND
  // config.json
  // ============================================================

  final appConfigService = AppConfigService();

  final AppConfig appConfig = await appConfigService.carregar();

  await logService.registrarSistema('CONFIGURACAO FRONTEND CARREGADA');

  await logService.registrarSistema('HOST: ${appConfig.host}');

  await logService.registrarSistema('PORTA: ${appConfig.porta}');

  // ============================================================
  // FULLSCREEN - WINDOWS / LINUX
  // ============================================================

  if (Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      fullScreen: false,
      center: true,
      backgroundColor: Colors.black,
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setFullScreen(false);
      await windowManager.show();
      await windowManager.focus();
    });
  }

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

  await logService.registrarSistema('COMPONENTE ATIVO DO PDV: $componente');

  // ============================================================
  // APP
  // ============================================================

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => PdvApp(
        config: config,
        componente: componente,
        appConfig: appConfig,
        logService: logService,
      ),
    ),
  );
}

class PdvApp extends StatelessWidget {
  final PdvConfig config;
  final int componente;
  final AppConfig appConfig;
  final PdvLogService logService;

  const PdvApp({
    super.key,
    required this.config,
    required this.componente,
    required this.appConfig,
    required this.logService,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PDV Convencional',
      initialBinding: PdvBinding(
        config: config,
        componente: componente,
        appConfig: appConfig,
        logService: logService,
      ),
      home: const HomeScreen(),
    );
  }
}
