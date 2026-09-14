import 'dart:async';
import 'dart:io';
import 'pdv_controller.dart';
import 'package:get/get.dart';
import 'package:pdv_convencional/config/pdv_paths.dart';

import '../models/app_config.dart';
import 'pdv_tela_controller.dart';

class PdvDescansoController extends GetxController {
  final AppConfig appConfig;
  final PdvTelaController telaController;
  final PdvController pdvController;

  PdvDescansoController({
    required this.appConfig,
    required this.telaController,
    required this.pdvController,
  });

  final RxBool telaDescansoAtiva = false.obs;

  Timer? _timer;
  Worker? _statusWorker;
  Worker? _fechamentoWorker;

  Worker? _gavetaWorker;
  Worker? _cargaWorker;
  Worker? _sangriaWorker;
  Worker? _leituraXWorker;
  Worker? _interfaceWorker;
  Worker? _cancelamentoWorker;
  Worker? _consultaWorker;

  bool get podeExibirDescanso {
    return habilitado &&
        telaController.status.value == 2 &&
        !pdvController.aguardandoFechamento.value &&
        !telaController.temTelaOperacionalAtiva;
  }

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

  void _processarTelaOperacional() {
    if (!podeExibirDescanso) {
      cancelarDescanso();
      return;
    }

    iniciarContagem();
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

    _fechamentoWorker = ever<bool>(pdvController.aguardandoFechamento, (
      aguardando,
    ) {
      if (aguardando) {
        cancelarDescanso();
        return;
      }

      if (telaController.status.value == 2) {
        iniciarContagem();
      }
    });

    _gavetaWorker = ever<bool>(
      telaController.telaAbrirGavetaAtiva,
      (_) => _processarTelaOperacional(),
    );

    _cargaWorker = ever<bool>(
      telaController.telaCarga,
      (_) => _processarTelaOperacional(),
    );

    _sangriaWorker = ever<bool>(
      telaController.telaSangria,
      (_) => _processarTelaOperacional(),
    );

    _leituraXWorker = ever<bool>(
      telaController.telaLeituraX,
      (_) => _processarTelaOperacional(),
    );

    _interfaceWorker = ever<bool>(
      telaController.telaInterfaceAtiva,
      (_) => _processarTelaOperacional(),
    );

    _cancelamentoWorker = ever<bool>(
      telaController.telaCancelamentoAtiva,
      (_) => _processarTelaOperacional(),
    );

    _consultaWorker = ever<bool>(
      telaController.telaConsultaAtiva,
      (_) => _processarTelaOperacional(),
    );

    if (podeExibirDescanso) {
      iniciarContagem();
    }
  }

  void _processarStatus(int novoStatus) {
    if (!habilitado) {
      return;
    }

    if (novoStatus != 2) {
      cancelarDescanso();
      return;
    }

    if (!podeExibirDescanso) {
      cancelarDescanso();
      return;
    }

    iniciarContagem();
  }

  void iniciarContagem() {
    if (!podeExibirDescanso) {
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
      if (!podeExibirDescanso) {
        return;
      }

      unawaited(abrirTelaDescanso());
    });
  }

  void registrarInteracao() {
    if (!podeExibirDescanso) {
      return;
    }

    if (telaDescansoAtiva.value) {
      unawaited(despertar());
      return;
    }

    iniciarContagem();
  }

  Future<void> abrirTelaDescanso() async {
    if (!podeExibirDescanso) {
      return;
    }

    if (telaDescansoAtiva.value) {
      return;
    }

    _cancelarTimer();

    telaDescansoAtiva.value = true;

    await Future.delayed(const Duration(milliseconds: 300));

    if (!telaDescansoAtiva.value) {
      return;
    }

    if (!podeExibirDescanso) {
      telaDescansoAtiva.value = false;
      return;
    }

    await _focarFlutter();
  }

  Future<bool> despertar() async {
    if (!telaDescansoAtiva.value) {
      return false;
    }

    telaDescansoAtiva.value = false;

    await _focarPdv();

    if (podeExibirDescanso) {
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
    _fechamentoWorker?.dispose();

    _gavetaWorker?.dispose();
    _cargaWorker?.dispose();
    _sangriaWorker?.dispose();
    _leituraXWorker?.dispose();
    _interfaceWorker?.dispose();
    _cancelamentoWorker?.dispose();
    _consultaWorker?.dispose();

    super.onClose();
  }
}
