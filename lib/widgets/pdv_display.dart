import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pdv_tela_controller.dart';

class PdvDisplayBar extends StatelessWidget {
  const PdvDisplayBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PdvTelaController>();

    return Obx(() {
      if (!controller.barraDisplayVisivel.value) {
        return const SizedBox.shrink();
      }

      final esquerda = controller.displayEsquerda.value;
      final direita = controller.displayDireita.value;

      // ============================================================
      // MENSAGEM CENTRALIZADA
      // Exemplo:
      // Atualiza embalagem atacado
      // ============================================================

      if (controller.displayCentralizado.value) {
        return Container(
          height: 58,
          color: const Color(0xFF05004F),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              esquerda,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        );
      }

      // ============================================================
      // COMPORTAMENTO QUE JÁ EXISTIA
      // ============================================================

      return Container(
        height: 48,
        color: const Color(0xFF05004F),
        child: direita.isEmpty
            // ======================================================
            // UMA ÚNICA INFORMAÇÃO
            // ======================================================
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    esquerda,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              )
            // ======================================================
            // DUAS INFORMAÇÕES
            //
            // DISPONIVEL | 61
            // IDENTIFICA CLIENTE | 1-CPF 3-CNPJ 0-SAI
            // PRODUTO | PREÇO
            // ======================================================
            : Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          esquerda,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // DIVISÓRIA
                  Container(
                    width: 2,
                    height: double.infinity,
                    color: Colors.white,
                  ),

                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          direita,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      );
    });
  }
}
