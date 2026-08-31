import 'dart:async';

import 'package:get/get.dart';

import '../controllers/pdv_tela_controller.dart';
import '../models/pdv_message.dart';
import '../services/pdv_message_parser.dart';
import '../services/pdv_socket_service.dart';

class PdvController extends GetxController {
  final PdvSocketService socketService;
  final PdvMessageParser parser;
  int _statusAnterior = -1;

  PdvController({required this.socketService, required this.parser});

  StreamSubscription<String>? _subscription;
  StreamSubscription<bool>? _conexaoSubscription;

  Timer? _timerReconexao;

  final RxBool conectado = false.obs;
  final RxBool conectando = true.obs;
  final RxBool conexaoInicializada = false.obs;

  final RxInt tentativaReconexao = 0.obs;

  // ============================================================
  // ESTADO DO PDV
  // ============================================================

  final RxInt statusPdv = 0.obs;

  // ============================================================
  // DISPLAY
  // ============================================================

  final RxString display = ''.obs;

  // ============================================================
  // SISTEMA / FOOTER
  // ============================================================

  final RxString sistemaRaw = ''.obs;

  final RxBool servidorOnline = false.obs;
  final RxBool gatewayOnline = false.obs;

  final RxString numeroPdv = ''.obs;
  final RxString operador = ''.obs;
  final RxString nomeOperador = ''.obs;

  // ============================================================
  // DEBUG
  // ============================================================

  final RxString ultimaMensagemRaw = ''.obs;

  // ============================================================
  // CONTROLLER DA TELA
  // ============================================================

  PdvTelaController get telaController {
    return Get.find<PdvTelaController>();
  }

  // ============================================================
  // INICIALIZAÇÃO
  // ============================================================
  static const String _hostPdv = '192.168.0.104';

  static const int _portaPdv = 8082;
  @override
  void onInit() {
    super.onInit();

    _subscription = socketService.mensagens.listen(_processarMensagem);

    _conexaoSubscription = socketService.conexaoStream.listen(
      _processarEstadoConexao,
    );
  }

  @override
  void onReady() {
    super.onReady();

    _conectarPdv();
  }

  Future<void> _conectarPdv() async {
    if (socketService.conectado) {
      conexaoInicializada.value = true;
      conectado.value = true;
      conectando.value = false;
      return;
    }

    if (socketService.conectando) {
      return;
    }

    conectando.value = true;

    final sucesso = await socketService.conectar(
      host: _hostPdv,
      port: _portaPdv,
    );

    conexaoInicializada.value = true;
    conectado.value = sucesso;
    conectando.value = false;

    if (!sucesso) {
      _iniciarReconexao();
    }
  }

  void _processarEstadoConexao(bool estaConectado) {
    conexaoInicializada.value = true;

    conectado.value = estaConectado;
    conectando.value = false;

    if (estaConectado) {
      tentativaReconexao.value = 0;

      _pararReconexao();

      print('============================');
      print('PDV CONECTADO');
      print('============================');

      return;
    }

    print('============================');
    print('PDV DESCONECTADO');
    print('============================');

    _iniciarReconexao();
  }

  void _iniciarReconexao() {
    if (_timerReconexao != null) {
      return;
    }

    _timerReconexao = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (socketService.conectado) {
        _pararReconexao();
        return;
      }

      if (socketService.conectando) {
        return;
      }

      tentativaReconexao.value++;

      print(
        'Tentativa de reconexão '
        '${tentativaReconexao.value}',
      );

      await _conectarPdv();
    });
  }

  void _pararReconexao() {
    _timerReconexao?.cancel();
    _timerReconexao = null;
  }

  // ============================================================
  // PROCESSAMENTO PRINCIPAL
  // ============================================================

  void _processarMensagem(String raw) {
    ultimaMensagemRaw.value = raw;

    final mensagem = parser.parse(raw);

    if (mensagem == null) {
      print('Mensagem não reconhecida: $raw');
      return;
    }

    switch (mensagem.tipo) {
      case PdvMessageType.digitacao:
        _processarDigitacao(mensagem);
        break;

      case PdvMessageType.status:
        _processarStatus(mensagem);
        break;

      case PdvMessageType.sistema:
        _processarSistema(mensagem);
        break;

      case PdvMessageType.funcao:
        _processarFuncao(mensagem);
        break;

      case PdvMessageType.informacao:
        _processarInformacao(mensagem);
        break;

      case PdvMessageType.interface:
        _processarInterface(mensagem);
        break;

      default:
        break;
    }
  }

  void _processarInformacao(PdvMessage mensagem) {
    print('======= RECEBEU I =======');
    print('RAW I: ${mensagem.raw}');

    final partes = mensagem.raw.split('|');

    if (partes.length < 2) {
      print('I| inválido');
      return;
    }

    final subtipo = partes[1].trim();

    print('SUBTIPO I: "$subtipo"');

    if (subtipo == '02') {
      _processarItemVenda(partes);
    }
    if (subtipo == '4' || subtipo == '10') {
      _processarRecebimento(partes);
      return;
    }
  }

  void _processarRecebimento(List<String> partes) {
    telaController.atualizarRecebimento(partes);
  }

  void _processarItemVenda(List<String> partes) {
    if (partes.length <= 10) {
      return;
    }

    final codigo = _parseDoublePdv(partes[5]);

    final descricao = partes[7].trim();

    final valorUnitario = _parseDoublePdv(partes[8]);

    final valorTotal = _parseDoublePdv(partes[9]);

    final quantidade = _parseDoublePdv(partes[10]);

    telaController.atualizarItemVenda(
      codigo: codigo,
      descricao: descricao,
      quantidade: quantidade,
      valorUnitario: valorUnitario,
      valorTotal: valorTotal,
    );
  }

  double _parseDoublePdv(String valor) {
    return double.tryParse(valor.trim().replaceAll(',', '.')) ?? 0.0;
  }

  // void _processarInformacao(PdvMessage mensagem) {
  //   final partes = mensagem.raw.split('|');

  //   if (partes.length < 2) {
  //     return;
  //   }

  //   final subtipo = partes[1].trim();

  //   switch (subtipo) {
  //     case '02':
  //       _processarItemVenda(partes);
  //       break;

  //     case '9':
  //       _processarInformacaoPreco(partes);
  //       break;

  //     default:
  //       print('INFORMAÇÃO NÃO TRATADA: ${mensagem.raw}');
  //       break;
  //   }
  // }

  // void _processarItemVenda(List<String> partes) {
  //   if (partes.length < 10) {
  //     return;
  //   }

  //   final codigoProduto = _parte(partes, 5).trim();

  //   final descricao = _parte(partes, 7).trim();

  //   final valorUnitario = _parte(partes, 8).trim();

  //   final valorTotal = _parte(partes, 9).trim();

  //   print('======= ITEM VENDA =======');
  //   print('CÓDIGO: $codigoProduto');
  //   print('DESCRIÇÃO: $descricao');
  //   print('VALOR UNITÁRIO: $valorUnitario');
  //   print('VALOR TOTAL: $valorTotal');
  //   print('==========================');

  //   telaController.atualizarItemVenda(
  //     codigo: codigoProduto,
  //     descricao: descricao,
  //     valorUnitario: valorUnitario,
  //     valorTotal: valorTotal,
  //   );
  // }

  void _processarInformacaoPreco(List<String> partes) {
    final valor = _parte(partes, 2).trim();

    print('INFORMAÇÃO PREÇO: $valor');
  }

  // ============================================================
  // E| STATUS
  // ============================================================

  void _processarStatus(PdvMessage mensagem) {
    final partes = mensagem.raw.split('|');

    if (partes.length < 2) {
      return;
    }

    final novoStatus = int.tryParse(partes[1].trim());

    if (novoStatus == null) {
      return;
    }

    statusPdv.value = novoStatus;

    telaController.atualizarStatus(novoStatus);

    print('STATUS PDV: $novoStatus');
  }

  // ============================================================
  // D| DISPLAY
  // ============================================================

  void _processarDigitacao(PdvMessage mensagem) {
    final partes = mensagem.raw.split('|');

    if (partes.length < 2) {
      return;
    }

    final esquerda = _parte(partes, 1);
    final direita = _parte(partes, 2);

    display.value = esquerda;

    telaController.atualizarDisplay(esquerda: esquerda, direita: direita);

    print('DISPLAY ESQUERDA: "$esquerda"');
    print('DISPLAY DIREITA: "$direita"');
  }

  // ============================================================
  // F| FUNÇÃO
  // ============================================================

  void _processarFuncao(PdvMessage mensagem) {
    final partes = mensagem.raw.split('|');

    if (partes.length < 3) {
      return;
    }

    final subtipo = partes[1].trim();

    final codigo = int.tryParse(partes[2].trim());

    if (codigo == null) {
      return;
    }

    print('FUNÇÃO PDV:');
    print('SUBTIPO: $subtipo');
    print('CÓDIGO: $codigo');
    print('RAW: ${mensagem.raw}');

    telaController.processarFuncao(subtipo: subtipo, codigo: codigo);

    // ============================================
    // 111 - CANCELAR VENDA
    // ============================================
    if (codigo == 111) {
      telaController.limparVenda();
    }
  }

  // ============================================================
  // X| INTERFACE
  // ============================================================

  void _processarInterface(PdvMessage mensagem) {
    final partes = mensagem.raw.split('|');

    if (partes.length < 3) {
      return;
    }

    final formulario = partes[1].trim();
    final comando = partes[2].trim().toUpperCase();

    if (formulario != 'frmGeral') {
      return;
    }

    switch (comando) {
      // ========================================================
      // X|frmGeral|CLS||
      // ========================================================

      case 'CLS':
        telaController.limparInterface();
        break;

      // ========================================================
      // X|frmGeral|Y|140|
      // ========================================================

      case 'Y':
        final y = _doubleParte(partes, 3);

        if (y != null) {
          telaController.alterarYInterface(y);
        }

        break;

      // ========================================================
      // X|frmGeral|FONTSIZE|10|
      // ========================================================

      case 'FONTSIZE':
        final tamanho = _doubleParte(partes, 3);

        if (tamanho != null) {
          telaController.alterarTamanhoFonteInterface(tamanho);
        }

        break;

      // ========================================================
      // X|frmGeral|FONTNAME|Courier|
      // ========================================================

      case 'FONTNAME':
        if (partes.length > 3) {
          telaController.alterarFonteInterface(partes[3].trim());
        }

        break;

      // ========================================================
      // X|frmGeral|FONTBOLD|S|
      // ========================================================

      case 'FONTBOLD':
        if (partes.length > 3) {
          final valor = partes[3].trim().toUpperCase();

          telaController.alterarBoldInterface(valor == 'S');
        }

        break;

      // ========================================================
      // X|frmGeral|PRINT| texto |S|
      //
      // IMPORTANTE:
      // NÃO usamos trim() no texto.
      //
      // Os espaços são necessários para preservar as colunas
      // enviadas pelo PDV.
      // ========================================================

      case 'PRINT':
        if (partes.length > 3) {
          final texto = partes[3];

          telaController.imprimirInterface(texto);
        }

        break;

      // ========================================================
      // X|frmGeral|FORECOLOR|0|
      //
      // Ainda não altera cor.
      // Mantemos o comando reconhecido para implementar depois.
      // ========================================================

      case 'FORECOLOR':
        break;

      default:
        break;
    }
  }

  // ============================================================
  // S| SISTEMA
  // ============================================================

  void _processarSistema(PdvMessage mensagem) {
    final partes = mensagem.raw.split('|');

    // Preservamos exatamente o RAW para o footer.
    sistemaRaw.value = mensagem.raw;

    // ==========================================================
    // SERVIDOR
    //
    // Exemplo:
    // S|Pdv:0256 ... Srv:ON|ON|256|...
    // ==========================================================

    if (partes.length > 1) {
      final informacao = partes[1];

      servidorOnline.value = RegExp(
        r'Srv:\s*ON',
        caseSensitive: false,
      ).hasMatch(informacao);
    }

    // ==========================================================
    // GATEWAY
    // ==========================================================

    if (partes.length > 2) {
      gatewayOnline.value = partes[2].trim().toUpperCase() == 'ON';
    }

    // ==========================================================
    // PDV
    // ==========================================================

    if (partes.length > 3) {
      numeroPdv.value = partes[3].trim();
    }

    // ==========================================================
    // OPERADOR
    // ==========================================================

    if (partes.length > 5) {
      operador.value = partes[5].trim();
    }

    // ==========================================================
    // NOME DO OPERADOR
    // ==========================================================

    if (partes.length > 6) {
      nomeOperador.value = partes[6].trim();
    }

    print('SERVIDOR: ${servidorOnline.value}');
    print('GATEWAY: ${gatewayOnline.value}');
    print('PDV: ${numeroPdv.value}');
    print('OPERADOR: ${operador.value}');
    print('NOME: ${nomeOperador.value}');
  }

  // ============================================================
  // ENVIO DE FUNÇÃO
  // ============================================================

  Future<void> enviarFuncao(int codigo) async {
    final comando = 'F|F|$codigo|';

    telaController.prepararFuncao(codigo);

    print('>>> FUNÇÃO: $comando');

    await socketService.enviar(comando);
  }

  // ============================================================
  // CONEXÃO
  // ============================================================

  Future<void> conectar({required String host, required int port}) async {
    await socketService.conectar(host: host, port: port);
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _parte(List<String> partes, int indice) {
    if (indice >= partes.length) {
      return '';
    }

    return partes[indice];
  }

  double? _doubleParte(List<String> partes, int indice) {
    if (indice >= partes.length) {
      return null;
    }

    return double.tryParse(partes[indice].trim());
  }

  // ============================================================
  // FINALIZAÇÃO
  // ============================================================

  @override
  void onClose() {
    _timerReconexao?.cancel();

    _subscription?.cancel();
    _conexaoSubscription?.cancel();

    super.onClose();
  }
}
