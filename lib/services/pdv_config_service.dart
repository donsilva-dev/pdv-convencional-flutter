import 'dart:io';

import 'package:pdv_convencional/models/pdv_config.dart';

import '../config/pdv_paths.dart';
import '../models/pdv_parametro.dart';

class PdvConfigService {
  Future<String> carregarXml() async {
    final file = File(PdvPaths.parametros);

    if (!await file.exists()) {
      throw Exception('XML não encontrado em: ${PdvPaths.parametros}');
    }

    return await file.readAsString();
  }

  Future<List<PdvParametro>> carregarParametros() async {
    final xml = await carregarXml();

    return _parseXml(xml);
  }

  Future<PdvConfig> carregarConfig() async {
    final parametros = await carregarParametros();

    return PdvConfig(parametros: parametros);
  }

  List<PdvParametro> _parseXml(String xml) {
    final parametros = <PdvParametro>[];

    final regex = RegExp(
      r'<ROW\s+'
      r'componente="([^"]*)"\s*'
      r'id="([^"]*)"\s*'
      r'parametro="([^"]*)"\s*/>',
    );

    for (final match in regex.allMatches(xml)) {
      final componente = int.tryParse(match.group(1) ?? '');

      final id = double.tryParse(match.group(2) ?? '');

      final parametro = match.group(3) ?? '';

      if (componente == null || id == null) {
        continue;
      }

      parametros.add(
        PdvParametro(componente: componente, id: id, parametro: parametro),
      );
    }

    print('TOTAL DE PARAMETROS CARREGADOS: ${parametros.length}');

    return parametros;
  }
}
