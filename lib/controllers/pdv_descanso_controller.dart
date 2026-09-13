import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:pdv_convencional/config/pdv_paths.dart';

import '../models/app_config.dart';
import 'pdv_tela_controller.dart';

class PdvDescansoController extends GetxController {
  final AppConfig appConfig;
  final PdvTelaController telaController;

  PdvDescansoController({
    required this.appConfig,
    required this.telaController,
  });

  final RxBool telaDescansoAtiva = false.obs;

  Timer? _timer;
  Worker? _statusWorker;

  bool get habilitado {
    return appConfig.possuiVideoDescanso;
  }

  String? get caminhoVideo {
    final nome = appConfig.videoDescanso;

    if (nome == null || nome.trim().isEmpty) {
      return null;
    }

    return '${PdvPaths.chamaVideo}${Platform.pathSeparator}$nome';
  }

  @override
  void onInit() {
    super.onInit();

    if (!habilitado) {
      return;
    }

    _statusWorker = ever<int>(telaController.status, (novoStatus) {
      _processarStatus(novoStatus);
    });

    if (telaController.status.value == 2) {
      iniciarContagem();
    }
  }

  void _processarStatus(int novoStatus) {
    if (!habilitado) {
      return;
    }

    // O descanso só pode existir em E|2.
    if (novoStatus != 2) {
      final estavaAberto = telaDescansoAtiva.value;

      telaDescansoAtiva.value = false;
      _cancelarTimer();

      if (estavaAberto) {
        unawaited(_focarPdv());
      }

      return;
    }

    iniciarContagem();
  }

  void iniciarContagem() {
    if (!habilitado) {
      return;
    }

    if (telaController.status.value != 2) {
      _cancelarTimer();
      return;
    }

    final caminho = caminhoVideo;

    if (caminho == null) {
      return;
    }

    if (!File(caminho).existsSync()) {
      print('VIDEO DE DESCANSO NÃO ENCONTRADO: $caminho');
      return;
    }

    _cancelarTimer();

    _timer = Timer(Duration(seconds: appConfig.tempoDescansoSegundos), () {
      if (telaController.status.value != 2) {
        return;
      }

      unawaited(abrirTelaDescanso());
    });
  }

  void registrarInteracao() {
    if (!habilitado) {
      return;
    }

    if (telaController.status.value != 2) {
      return;
    }

    if (telaDescansoAtiva.value) {
      unawaited(despertar());
      return;
    }

    iniciarContagem();
  }

  Future<void> abrirTelaDescanso() async {
    if (!habilitado) {
      return;
    }

    if (telaController.status.value != 2) {
      return;
    }

    if (telaDescansoAtiva.value) {
      return;
    }

    _cancelarTimer();

    telaDescansoAtiva.value = true;

    // Dá tempo para o widget do vídeo entrar na árvore
    // e o FocusNode interno ser criado.
    await Future.delayed(const Duration(milliseconds: 300));

    if (!telaDescansoAtiva.value) {
      return;
    }

    if (telaController.status.value != 2) {
      return;
    }

    await _focarFlutter();
  }

  Future<bool> despertar() async {
    if (!telaDescansoAtiva.value) {
      return false;
    }

    telaDescansoAtiva.value = false;

    // A tecla que chegou ao Flutter morre aqui.
    // Depois devolvemos o teclado ao PDV.
    await _focarPdv();

    if (telaController.status.value == 2) {
      iniciarContagem();
    }

    return true;
  }

  void cancelarDescanso() {
    final estavaAberto = telaDescansoAtiva.value;

    telaDescansoAtiva.value = false;
    _cancelarTimer();

    if (estavaAberto) {
      unawaited(_focarPdv());
    }
  }

  void _cancelarTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _focarFlutter() async {
    if (!Platform.isLinux) {
      return;
    }

    await _focarJanela('com.example.pdv_convencional', 'FLUTTER');
  }

  Future<void> _focarPdv() async {
    if (!Platform.isLinux) {
      return;
    }

    await _focarJanela('unnamed.pdvlinuxnfce', 'PDV');
  }

  Future<void> _focarJanela(String classe, String nome) async {
    try {
      final resultado = await Process.run(
        '/usr/bin/wmctrl',
        ['-lx'],
        environment: {'DISPLAY': ':0'},
      );

      if (resultado.exitCode != 0) {
        print(
          'ERRO WMCTRL AO LISTAR JANELAS: '
          '${resultado.stderr}',
        );
        return;
      }

      final linhas = resultado.stdout.toString().split('\n');

      String? idJanela;

      for (final linha in linhas) {
        if (!linha.contains(classe)) {
          continue;
        }

        final partes = linha.trim().split(RegExp(r'\s+'));

        if (partes.isNotEmpty) {
          idJanela = partes.first;
        }

        break;
      }

      if (idJanela == null) {
        print('JANELA $nome NÃO ENCONTRADA: $classe');
        return;
      }

      final foco = await Process.run(
        '/usr/bin/wmctrl',
        ['-i', '-a', idJanela],
        environment: {'DISPLAY': ':0'},
      );

      if (foco.exitCode != 0) {
        print(
          'ERRO AO DAR FOCO EM $nome: '
          '${foco.stderr}',
        );
        return;
      }

      print('FOCO -> $nome | $idJanela');
    } catch (e) {
      print('ERRO AO ALTERAR FOCO PARA $nome: $e');
    }
  }

  @override
  void onClose() {
    _cancelarTimer();
    _statusWorker?.dispose();

    super.onClose();
  }
}
