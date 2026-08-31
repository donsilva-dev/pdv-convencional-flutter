import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/pdv_conexao_config.dart';

class PdvConexaoConfigService {
  Future<PdvConexaoConfig> carregar() async {
    final jsonString = await rootBundle.loadString(
      'assets/config/pdv_conexao.json',
    );

    final json = jsonDecode(jsonString) as Map<String, dynamic>;

    return PdvConexaoConfig.fromJson(json);
  }
}
