import 'dart:io';

import '../config/pdv_paths.dart';

class VmixConfigService {
  int carregarComponente() {
    try {
      final arquivo = File(PdvPaths.vmixConfig);

      if (!arquivo.existsSync()) {
        print('VMIX.CFG NÃO ENCONTRADO: ${PdvPaths.vmixConfig}');
        print('COMPONENTE UTILIZADO: 0');
        return 0;
      }

      final linhas = arquivo.readAsLinesSync();

      int? grupo;
      int? numeroComponente;

      for (final linhaOriginal in linhas) {
        final linha = linhaOriginal.trim();

        if (linha.isEmpty) {
          continue;
        }

        if (linha.startsWith('#') || linha.startsWith(';')) {
          continue;
        }

        final indiceIgual = linha.indexOf('=');

        if (indiceIgual == -1) {
          continue;
        }

        final chave = linha
            .substring(0, indiceIgual)
            .trim()
            .toUpperCase();

        final valor = linha
            .substring(indiceIgual + 1)
            .trim();

        final numero = int.tryParse(valor);

        if (numero == null) {
          continue;
        }

        if (chave == 'GRUPO') {
          grupo = numero;
        }

        if (chave == 'NUMEROCOMPONENTE') {
          numeroComponente = numero;
        }
      }

      // GRUPO tem prioridade.
      if (grupo != null) {
        print('GRUPO ENCONTRADO: $grupo');
        print('COMPONENTE UTILIZADO: $grupo');
        return grupo;
      }

      // Sem GRUPO, usa NUMEROCOMPONENTE.
      if (numeroComponente != null) {
        print('NUMEROCOMPONENTE ENCONTRADO: $numeroComponente');
        print('COMPONENTE UTILIZADO: $numeroComponente');
        return numeroComponente;
      }

      // Sem nenhum dos dois.
      print('GRUPO E NUMEROCOMPONENTE NÃO DEFINIDOS');
      print('COMPONENTE UTILIZADO: 0');

      return 0;
    } catch (e) {
      print('ERRO AO LER VMIX.CFG: $e');
      print('COMPONENTE UTILIZADO: 0');

      return 0;
    }
  }
}
