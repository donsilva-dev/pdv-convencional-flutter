import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pdv_convencional/controllers/pdv_controller.dart';
import 'package:pdv_convencional/controllers/pdv_descanso_controller.dart';
import 'package:pdv_convencional/widgets/pdv_abrir_gaveta.dart';
import 'package:pdv_convencional/widgets/pdv_aguardando_fechamento.dart';
import 'package:pdv_convencional/widgets/pdv_carga.dart';
import 'package:pdv_convencional/widgets/pdv_conexao_overlay.dart';
import 'package:pdv_convencional/widgets/pdv_consulta_overlay.dart';
import 'package:pdv_convencional/widgets/pdv_entrada_operador.dart';
import 'package:pdv_convencional/widgets/pdv_fechado.dart';
import 'package:pdv_convencional/widgets/pdv_imp_de_leitura_x.dart';
import 'package:pdv_convencional/widgets/pdv_recebimento_overlay.dart';
import 'package:pdv_convencional/widgets/pdv_display.dart';
import 'package:pdv_convencional/widgets/pdv_footer.dart';
import 'package:pdv_convencional/widgets/pdv_interface_overlay.dart';
import 'package:pdv_convencional/widgets/pdv_saida_operador.dart';
import 'package:pdv_convencional/widgets/pdv_sandria.dart';
import 'package:pdv_convencional/widgets/pdv_venda_overlay.dart';
import 'package:pdv_convencional/widgets/pdv_tela_descanso.dart';

import '../config/pdv_paths.dart';
import '../controllers/pdv_tela_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FocusNode _keyboardFocus = FocusNode(debugLabel: 'PDV_KEYBOARD_FOCUS');

  late final PdvTelaController telaController;
  late final PdvController pdvController;
  late final PdvDescansoController descansoController;

  @override
  void initState() {
    super.initState();

    telaController = Get.find<PdvTelaController>();
    pdvController = Get.find<PdvController>();
    descansoController = Get.find<PdvDescansoController>();

    // Garante foco no teclado assim que a tela estiver pronta.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _solicitarFoco();
      }
    });
  }

  // ============================================================
  // FOCO DO TECLADO
  // ============================================================

  void _solicitarFoco() {
    if (!_keyboardFocus.hasFocus) {
      _keyboardFocus.requestFocus();
    }
  }

  // ============================================================
  // TECLADO
  // ============================================================

  void _processarTecla(KeyEvent event) {
    // Evita disparar a mesma tecla várias vezes por KeyUpEvent.
    if (event is! KeyDownEvent) {
      return;
    }

    // ==========================================================
    // TELA DE DESCANSO
    //
    // Se o vídeo estiver aberto:
    // - fecha o vídeo;
    // - reinicia a contagem;
    // - NÃO envia essa tecla para o PDV.
    // ==========================================================

    if (descansoController.telaDescansoAtiva.value) {
      descansoController.despertar();
      return;
    }

    // ==========================================================
    // INTERAÇÃO NO STATUS 2
    //
    // Qualquer tecla enquanto estiver disponível reinicia
    // os 60 segundos.
    // ==========================================================

    if (telaController.status.value == 2) {
      descansoController.registrarInteracao();
    }

    final logicalKey = event.logicalKey;
    final caractere = event.character;

    // ==========================================================
    // NÚMEROS 0 A 9
    //
    // Funciona tanto com teclado normal quanto scanner HID
    // quando o scanner envia caracteres numéricos.
    // ==========================================================

    if (caractere != null && RegExp(r'^[0-9]$').hasMatch(caractere)) {
      pdvController.enviarTecla(caractere);
      return;
    }

    // ==========================================================
    // ENTER
    // ==========================================================

    if (logicalKey == LogicalKeyboardKey.enter ||
        logicalKey == LogicalKeyboardKey.numpadEnter) {
      pdvController.enviarTecla('ENTER');
      return;
    }

    // ==========================================================
    // ESC
    // ==========================================================

    if (logicalKey == LogicalKeyboardKey.escape) {
      pdvController.enviarTecla('ESC');
      return;
    }

    // ==========================================================
    // BACKSPACE
    // ==========================================================

    if (logicalKey == LogicalKeyboardKey.backspace) {
      pdvController.enviarTecla('BACKSPACE');
      return;
    }
  }

  // ============================================================
  // CLIQUE / TOUCH
  // ============================================================

  void _registrarInteracaoTela() {
    _solicitarFoco();

    if (descansoController.telaDescansoAtiva.value) {
      descansoController.despertar();
      return;
    }

    if (telaController.status.value == 2) {
      descansoController.registrarInteracao();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocus,
      autofocus: true,
      onKeyEvent: _processarTecla,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _registrarInteracaoTela,
        child: Scaffold(
          body: Obx(() {
            final nomeImagem = telaController.imagem.value;

            if (nomeImagem.isEmpty) {
              return const Center(child: Text('Aguardando PDV...'));
            }

            final caminho = PdvPaths.imagem(nomeImagem);
            final arquivo = File(caminho);

            // ==================================================
            // DESCANSO
            // ==================================================

            final status = telaController.status.value;

            final descansoAtivo = descansoController.telaDescansoAtiva.value;

            return Stack(
              children: [
                // ==================================================
                // TELA DO PDV
                // ==================================================
                Positioned.fill(
                  child: arquivo.existsSync()
                      ? Image.file(arquivo, fit: BoxFit.fill)
                      : Center(child: Text('Imagem não encontrada:\n$caminho')),
                ),

                // ==================================================
                // VENDA
                //
                // Durante cancelamento escondemos somente os dados
                // da venda.
                // ==================================================
                if (!telaController.telaCancelamentoAtiva.value)
                  const PdvVendaOverlay(),

                // ==================================================
                // RECEBIMENTO
                // ==================================================
                if (!telaController.telaCancelamentoAtiva.value)
                  const PdvRecebimentoOverlay(),

                // ==================================================
                // CONSULTA
                // ==================================================
                const PdvConsultaOverlay(),

                // ==================================================
                // INTERFACE DINÂMICA
                // ==================================================
                const PdvInterfaceOverlay(),

                // ==================================================
                // ABRIR GAVETA
                // ==================================================
                if (telaController.telaAbrirGavetaAtiva.value)
                  const Positioned.fill(child: PdvAbrirGaveta()),

                // ==================================================
                // RECEBE CARGA
                // ==================================================
                if (telaController.telaCarga.value)
                  const Positioned.fill(child: PdvCarga()),

                // ==================================================
                // AGUARDANDO FECHAMENTO
                // ==================================================
                if (pdvController.aguardandoFechamento.value)
                  const Positioned.fill(child: PdvAguardandoFechamento()),

                // ==================================================
                // TELA SANGRIA
                // ==================================================
                if (telaController.telaSangria.value)
                  const Positioned.fill(child: PdvSandria()),

                // ==================================================
                // TELA LEITURA X
                // ==================================================
                if (telaController.telaLeituraX.value)
                  const Positioned.fill(child: PdvImpDeLeituraX()),

                // ==================================================
                // TELA SAIDA OPERADOR
                // ==================================================
                if (telaController.telaSaidaOperador.value)
                  const Positioned.fill(child: PdvSaidaOperador()),

                // ==================================================
                // TELA ENTRADA OPERADOR
                // ==================================================
                if (telaController.telaEntradaOperador.value)
                  const Positioned.fill(child: PdvEntradaOperador()),

                // ==================================================
                // TELA FECHADO
                // ==================================================
                if (telaController.telaPdvFechado.value)
                  const Positioned.fill(child: PdvFechado()),

                // ==================================================
                // DISPLAY INFERIOR
                // ==================================================
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 30,
                  child: PdvDisplayBar(),
                ),

                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: PdvFooter(),
                ),

                // ==================================================
                // TELA DE DESCANSO
                //
                // Só pode existir no STATUS 2.
                // ==================================================
                if (descansoAtivo &&
                    status == 2 &&
                    !pdvController.aguardandoFechamento.value &&
                    !telaController.temTelaOperacionalAtiva)
                  const Positioned.fill(child: PdvTelaDescanso()),

                // ==================================================
                // CONEXÃO - SEMPRE POR ÚLTIMO
                // ==================================================
                const Positioned.fill(child: PdvConexaoOverlay()),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ============================================================
  // FINALIZAÇÃO
  // ============================================================

  @override
  void dispose() {
    _keyboardFocus.dispose();

    super.dispose();
  }
}
