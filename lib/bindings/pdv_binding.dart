import 'package:get/get.dart';
import 'package:pdv_convencional/models/app_config.dart';
import 'package:pdv_convencional/services/pdv_log_service.dart';

import '../controllers/pdv_controller.dart';
import '../controllers/pdv_tela_controller.dart';
import '../models/pdv_config.dart';
import '../services/pdv_config_service.dart';
import '../services/pdv_message_parser.dart';
import '../services/pdv_socket_service.dart';

class PdvBinding extends Bindings {
  final PdvConfig config;
  final int componente;
  final AppConfig appConfig;
  final PdvLogService logService;

  PdvBinding({
    required this.config,
    required this.componente,
    required this.appConfig,
    required this.logService,
  });

  @override
  void dependencies() {
    // LOG
    Get.put<PdvLogService>(logService, permanent: true);

    // CONFIG DO FRONTEND
    Get.put<AppConfig>(appConfig, permanent: true);

    // SOCKET
    Get.put<PdvSocketService>(
      PdvSocketService(config: appConfig, logService: logService),
      permanent: true,
    );

    // PARSER
    Get.put<PdvMessageParser>(PdvMessageParser(), permanent: true);

    // CONFIG SERVICE
    Get.put<PdvConfigService>(PdvConfigService(), permanent: true);

    // TELA / RENDERER
    Get.put<PdvTelaController>(
      PdvTelaController(config.parametros, componente: componente),
      permanent: true,
    );

    // PDV
    Get.put<PdvController>(
      PdvController(
        socketService: Get.find<PdvSocketService>(),
        parser: Get.find<PdvMessageParser>(),
      ),
      permanent: true,
    );
  }
}
