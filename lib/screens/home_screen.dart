import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:pdv_convencional/controllers/pdv_controller.dart';
import 'package:pdv_convencional/widgets/pdv_conexao_overlay.dart';
import 'package:pdv_convencional/widgets/pdv_consulta_overlay.dart';
import 'package:pdv_convencional/widgets/pdv_recebimento_overlay.dart';
import 'package:pdv_convencional/widgets/pdv_display.dart';
import 'package:pdv_convencional/widgets/pdv_footer.dart';
import 'package:pdv_convencional/widgets/pdv_interface_overlay.dart';
import 'package:pdv_convencional/widgets/pdv_venda_overlay.dart';

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

  @override
  void initState() {
    super.initState();

    telaController = Get.find<PdvTelaController>();
    pdvController = Get.find<PdvController>();

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
    // Evita disparar a mesma tecla várias vezes
    // por KeyUpEvent.
    if (event is! KeyDownEvent) {
      return;
    }

    final logicalKey = event.logicalKey;
    final caractere = event.character;

    // ==========================================================
    // NÚMEROS 0 A 9
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocus,
      autofocus: true,
      onKeyEvent: _processarTecla,

      // Se por algum motivo a janela perder o foco interno,
      // um clique na tela devolve o foco ao PDV.
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _solicitarFoco,
        child: Scaffold(
          body: Obx(() {
            final nomeImagem = telaController.imagem.value;

            if (nomeImagem.isEmpty) {
              return const Center(child: Text('Aguardando PDV...'));
            }

            final caminho = PdvPaths.imagem(nomeImagem);
            final arquivo = File(caminho);

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
                // DISPLAY INFERIOR
                // ==================================================
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 30,
                  child: PdvDisplayBar(),
                ),

                // ==================================================
                // FOOTER
                // ==================================================
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: PdvFooter(),
                ),

                // ==================================================
                // CONEXÃO
                //
                // SEMPRE POR ÚLTIMO
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
