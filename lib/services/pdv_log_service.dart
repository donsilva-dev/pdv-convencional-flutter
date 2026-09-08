import 'dart:async';
import 'dart:io';

import '../config/pdv_paths.dart';

class PdvLogService {
  Future<void> _fila = Future.value();

  Future<void> inicializar() async {
    final diretorio = Directory(PdvPaths.logs);

    if (!await diretorio.exists()) {
      await diretorio.create(recursive: true);
    }

    await registrarSistema('==============================================');

    await registrarSistema('FRONTEND PDV INICIADO');

    await registrarSistema('BUNDLE: ${PdvPaths.bundle}');

    await registrarSistema('==============================================');
  }

  String _nomeArquivo() {
    final agora = DateTime.now();

    final dia = agora.day.toString().padLeft(2, '0');
    final mes = agora.month.toString().padLeft(2, '0');
    final ano = agora.year.toString().substring(2);

    final semana = _diaSemana(agora.weekday);

    return 'log_pdv_${dia}-${mes}-${ano}_$semana.log';
  }

  String _diaSemana(int dia) {
    switch (dia) {
      case DateTime.monday:
        return 'segunda';
      case DateTime.tuesday:
        return 'terca';
      case DateTime.wednesday:
        return 'quarta';
      case DateTime.thursday:
        return 'quinta';
      case DateTime.friday:
        return 'sexta';
      case DateTime.saturday:
        return 'sabado';
      case DateTime.sunday:
        return 'domingo';
      default:
        return 'desconhecido';
    }
  }

  String _dataHora() {
    final agora = DateTime.now();

    final dia = agora.day.toString().padLeft(2, '0');
    final mes = agora.month.toString().padLeft(2, '0');

    final ano = agora.year.toString().substring(2);

    final hora = agora.hour.toString().padLeft(2, '0');
    final minuto = agora.minute.toString().padLeft(2, '0');
    final segundo = agora.second.toString().padLeft(2, '0');

    return '$dia/$mes/$ano $hora:$minuto:$segundo';
  }

  Future<void> recebido(String mensagem) {
    return _gravar('-> $mensagem');
  }

  Future<void> enviado(String mensagem) {
    return _gravar('<- $mensagem');
  }

  Future<void> registrarSistema(String mensagem) {
    return _gravar('[SISTEMA] $mensagem');
  }

  Future<void> registrarConexao(String mensagem) {
    return _gravar('[CONEXAO] $mensagem');
  }

  Future<void> registrarErro(
    String mensagem, [
    Object? erro,
    StackTrace? stackTrace,
  ]) async {
    await _gravar(
      '[ERRO] $mensagem'
      '${erro != null ? ' | $erro' : ''}',
    );

    if (stackTrace != null) {
      await _gravar('[STACK] $stackTrace');
    }
  }

  Future<void> registrarAcao(String mensagem) {
    return _gravar('[ACAO] $mensagem');
  }

  Future<void> _gravar(String mensagem) {
    _fila = _fila.then((_) async {
      try {
        final diretorio = Directory(PdvPaths.logs);

        if (!await diretorio.exists()) {
          await diretorio.create(recursive: true);
        }

        final arquivo = File(
          '${PdvPaths.logs}'
          '${Platform.pathSeparator}'
          '${_nomeArquivo()}',
        );

        await arquivo.writeAsString(
          '${_dataHora()} $mensagem\n',
          mode: FileMode.append,
          flush: true,
        );
      } catch (e) {
        print('ERRO AO GRAVAR LOG: $e');
      }
    });

    return _fila;
  }
}
