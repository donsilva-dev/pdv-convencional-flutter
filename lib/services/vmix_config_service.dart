import 'dart:convert';
import 'dart:io';

import '../config/pdv_paths.dart';

class VmixConfigService {
  int carregarComponente() {
    try {
      final arquivo = File(PdvPaths.vmixConfig);

      if (!arquivo.existsSync()) {
        print('VMIX.CFG NAO ENCONTRADO: ${PdvPaths.vmixConfig}');
        print('COMPONENTE UTILIZADO: 0');
        return 0;
      }

      // ============================================================
      // LEITURA DO VMIX.CFG
      // ============================================================
      //
      // O vmix.cfg pode ter sido gerado em ANSI / ISO-8859-1.
      // Por isso não usamos readAsLinesSync(), que espera UTF-8.
      // ============================================================

      final bytes = arquivo.readAsBytesSync();

      final conteudo = latin1.decode(bytes, allowInvalid: true);

      final linhas = const LineSplitter().convert(conteudo);

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

        final chave = linha.substring(0, indiceIgual).trim().toUpperCase();

        final valor = linha.substring(indiceIgual + 1).trim();

        if (chave == 'GRUPO') {
          final numero = int.tryParse(valor);

          if (numero != null) {
            grupo = numero;
          }
        }

        if (chave == 'NUMEROCOMPONENTE') {
          final numero = int.tryParse(valor);

          if (numero != null) {
            numeroComponente = numero;
          }
        }
      }

      // ============================================================
      // PRIORIDADE 1 - GRUPO
      // ============================================================

      if (grupo != null) {
        print('GRUPO ENCONTRADO: $grupo');
        print('COMPONENTE UTILIZADO: $grupo');

        return grupo;
      }

      // ============================================================
      // PRIORIDADE 2 - NUMEROCOMPONENTE
      // ============================================================

      if (numeroComponente != null) {
        print('NUMEROCOMPONENTE ENCONTRADO: $numeroComponente');

        print('COMPONENTE UTILIZADO: $numeroComponente');

        return numeroComponente;
      }

      // ============================================================
      // PADRAO
      // ============================================================

      print('GRUPO E NUMEROCOMPONENTE NAO DEFINIDOS');
      print('COMPONENTE UTILIZADO: 0');

      return 0;
    } catch (e) {
      print('ERRO AO LER VMIX.CFG: $e');
      print('COMPONENTE UTILIZADO: 0');

      return 0;
    }
  }
}
