import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pdv_tela_controller.dart';

class PdvInterfaceOverlay extends StatelessWidget {
  const PdvInterfaceOverlay({super.key});

  // ============================================================
  // CONFIGURAÇÃO VISUAL
  // ============================================================

  // Multiplica o FONTSIZE recebido do PDV.
  //
  // FONTSIZE 10 -> 18px no Flutter.
  static const double escalaFonte = 1.80;

  // Espaçamento vertical entre as linhas.
  //
  // Aumentamos um pouco para o texto "respirar".
  static const double escalaVertical = 1.60;

  // Área horizontal disponível para os textos.
  static const double larguraConteudo = 0.86;

  // Move o bloco inteiro para a esquerda.
  static const double deslocamentoEsquerda = 45;

  // Posição vertical inicial.
  static const double topConteudo = 190;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PdvTelaController>();

    return Positioned.fill(
      child: IgnorePointer(
        child: Obx(() {
          if (!controller.telaInterfaceAtiva.value) {
            return const SizedBox.shrink();
          }

          final elementos = controller.elementosInterface.toList();

          if (elementos.isEmpty) {
            return const SizedBox.shrink();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final larguraTela = constraints.maxWidth;

              final larguraBloco = larguraTela * larguraConteudo;

              // =================================================
              // CENTRALIZA E DEPOIS MOVE UM POUCO PARA A ESQUERDA
              // =================================================

              final leftCentralizado = (larguraTela - larguraBloco) / 2;

              final left = (leftCentralizado - deslocamentoEsquerda).clamp(
                20.0,
                larguraTela,
              );

              // =================================================
              // PRIMEIRO Y COMO REFERÊNCIA
              // =================================================

              final primeiroY = elementos.first.y;

              return Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.none,
                children: elementos.map((item) {
                  final diferencaY = item.y - primeiroY;

                  final top = topConteudo + (diferencaY * escalaVertical);

                  return Positioned(
                    left: left,
                    top: top,
                    width: larguraBloco,
                    child: Text(
                      item.texto,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        color: Colors.black,

                        fontSize: item.fontSize * escalaFonte,

                        fontFamily: _resolverFonte(item.fontName),

                        fontWeight: item.bold
                            ? FontWeight.bold
                            : FontWeight.normal,

                        height: 1,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          );
        }),
      ),
    );
  }

  String? _resolverFonte(String fontName) {
    final fonte = fontName.trim().toLowerCase();

    if (fonte == 'courier') {
      return 'Courier New';
    }

    if (fonte == 'arial') {
      return 'Arial';
    }

    return null;
  }
}
