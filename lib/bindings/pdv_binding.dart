import 'package:get/get.dart';

import '../controllers/pdv_controller.dart';
import '../controllers/pdv_tela_controller.dart';
import '../models/pdv_config.dart';
import '../services/pdv_config_service.dart';
import '../services/pdv_message_parser.dart';
import '../services/pdv_socket_service.dart';

class PdvBinding extends Bindings {
  final PdvConfig config;
  final int componente;

  PdvBinding({
    required this.config,
    required this.componente,
  });

  @override
  void dependencies() {
    // SOCKET
    Get.put<PdvSocketService>(
      PdvSocketService(),
      permanent: true,
    );

    // PARSER
    Get.put<PdvMessageParser>(
      PdvMessageParser(),
      permanent: true,
    );

    // CONFIG SERVICE
    Get.put<PdvConfigService>(
      PdvConfigService(),
      permanent: true,
    );

    // TELA / RENDERER
    Get.put<PdvTelaController>(
      PdvTelaController(
        config.parametros,
        componente: componente,
      ),
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
