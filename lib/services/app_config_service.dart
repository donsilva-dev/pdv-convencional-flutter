import 'dart:convert';
import 'dart:io';

import '../config/pdv_paths.dart';
import '../models/app_config.dart';

class AppConfigService {
  Future<AppConfig> carregar() async {
    try {
      final arquivo = File(PdvPaths.config);

      if (!await arquivo.exists()) {
        final config = AppConfig.padrao();

        await arquivo.writeAsString(
          const JsonEncoder.withIndent('  ').convert(config.toJson()),
          flush: true,
        );

        return config;
      }

      final conteudo = await arquivo.readAsString();

      if (conteudo.trim().isEmpty) {
        return AppConfig.padrao();
      }

      final json = jsonDecode(conteudo);

      if (json is! Map<String, dynamic>) {
        return AppConfig.padrao();
      }

      return AppConfig.fromJson(json);
    } catch (e) {
      print('ERRO AO CARREGAR CONFIG.JSON: $e');

      return AppConfig.padrao();
    }
  }
}
