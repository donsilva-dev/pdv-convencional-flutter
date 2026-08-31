import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdv_convencional/widgets/pdv_conexao_overlay.dart';
import 'package:pdv_convencional/widgets/pdv_recebimento_overlay.dart';

import 'package:pdv_convencional/widgets/pdv_display.dart';
import 'package:pdv_convencional/widgets/pdv_footer.dart';
import 'package:pdv_convencional/widgets/pdv_interface_overlay.dart';
import 'package:pdv_convencional/widgets/pdv_venda_overlay.dart';

import '../config/pdv_paths.dart';
import '../controllers/pdv_tela_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PdvTelaController>();

    return Scaffold(
      body: Obx(() {
        final nomeImagem = controller.imagem.value;

        if (nomeImagem.isEmpty) {
          return const Center(child: Text('Aguardando PDV...'));
        }

        final caminho = '${PdvPaths.pictures}\\$nomeImagem';
        final arquivo = File(caminho);

        return Stack(
          children: [
            // ==================================================
            // TELA DO PDV
            // Imagem configurada pelo XML
            // Ex.: estado1.bmp, venda.bmp, consulta.bmp...
            // ==================================================
            Positioned.fill(
              child: arquivo.existsSync()
                  ? Image.file(arquivo, fit: BoxFit.fill)
                  : Center(
                      child: Text(
                        'Imagem não encontrada:\n'
                        '$caminho',
                      ),
                    ),
            ),

            // ==================================================
            // COMPONENTES DA TELA DE VENDA
            //
            // Aqui serão desenhados os labels configurados
            // pelos parâmetros do XML.
            //
            // Ex.:
            // 1203 -> código do produto
            //
            // Só será exibido quando status == 3.
            // ==================================================
            const PdvVendaOverlay(),
            const PdvRecebimentoOverlay(),
            // ==================================================
            // INTERFACE DINÂMICA
            //
            // Comandos:
            // X|frmGeral|...
            //
            // Ex.: função 198.
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
            const Positioned(left: 0, right: 0, bottom: 0, child: PdvFooter()),
            // SEMPRE POR ÚLTIMO
            const Positioned.fill(child: PdvConexaoOverlay()),
          ],
        );
      }),
    );
  }
}
