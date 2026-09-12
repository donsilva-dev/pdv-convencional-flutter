import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../controllers/pdv_tela_controller.dart';
import '../models/pdv_label_config.dart';

class PdvRecebimentoOverlay extends StatelessWidget {
  const PdvRecebimentoOverlay({super.key});

  // =========================================================
  // BASE DE COORDENADAS DO PDV
  // =========================================================

  static const double larguraBasePdv = 9000.0;
  static const double alturaBasePdv = 7000.0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PdvTelaController>();

    return Positioned.fill(
      child: IgnorePointer(
        child: Obx(() {
          if (controller.status.value != 4) {
            return const SizedBox.shrink();
          }

          // =====================================================
          // ESTADO REATIVO DO RECEBIMENTO
          // =====================================================
          //
          // Quando chegar I|4 ou I|10, qualquer alteração nesses
          // valores fará o overlay reconstruir imediatamente.
          // =====================================================

          controller.totalCompra.value;
          controller.valorPago.value;
          controller.valorAPagar.value;
          controller.troco.value;

          return LayoutBuilder(
            builder: (context, constraints) {
              final larguraTela = constraints.maxWidth;
              final alturaTela = constraints.maxHeight;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // =============================================
                  // 1116 - TOTAL DA COMPRA
                  // =============================================
                  _buildLabel(
                    config: controller.labelTotalCompra.value,
                    texto: controller.totalCompraFormatado,
                    larguraTela: larguraTela,
                    alturaTela: alturaTela,
                  ),

                  // =============================================
                  // 1104 - VALOR PAGO
                  // =============================================
                  _buildLabel(
                    config: controller.labelValorPago.value,
                    texto: controller.valorPagoFormatado,
                    larguraTela: larguraTela,
                    alturaTela: alturaTela,
                  ),

                  // =============================================
                  // 1105 - VALOR A PAGAR
                  // =============================================
                  _buildLabel(
                    config: controller.labelValorAPagar.value,
                    texto: controller.valorAPagarFormatado,
                    larguraTela: larguraTela,
                    alturaTela: alturaTela,
                  ),

                  // =============================================
                  // 1106 - TROCO
                  // =============================================
                  _buildLabel(
                    config: controller.labelTroco.value,
                    texto: controller.trocoFormatado,
                    larguraTela: larguraTela,
                    alturaTela: alturaTela,
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  // =========================================================
  // ESCALA X
  // =========================================================

  double _scaleX(double larguraTela) {
    return larguraTela / larguraBasePdv;
  }

  // =========================================================
  // ESCALA Y
  // =========================================================

  double _scaleY(double alturaTela) {
    return alturaTela / alturaBasePdv;
  }

  // =========================================================
  // LABEL PADRÃO DO RECEBIMENTO
  // =========================================================

  Widget _buildLabel({
    required PdvLabelConfig? config,
    required String texto,
    required double larguraTela,
    required double alturaTela,
  }) {
    if (config == null || !config.visivel || texto.isEmpty) {
      return const SizedBox.shrink();
    }

    final scaleX = _scaleX(larguraTela);
    final scaleY = _scaleY(alturaTela);

    return Positioned(
      left: config.left * scaleX,
      top: config.top * scaleY,
      width: config.width * scaleX,
      height: config.height * scaleY,
      child: ClipRect(
        child: Align(
          alignment: _resolverAlinhamento(config.alinhamento),
          child: Text(
            texto,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
            style: TextStyle(
              color: config.corFonte,
              fontFamily: _resolverFonte(config.fontFamily),

              // O tamanho da fonte vem diretamente do XML.
              // Não aplicamos scaleX/scaleY aqui.
              fontSize: config.fontSize,

              fontWeight: config.bold ? FontWeight.bold : FontWeight.normal,

              fontStyle: config.italic ? FontStyle.italic : FontStyle.normal,

              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // ALINHAMENTO
  // =========================================================

  Alignment _resolverAlinhamento(int valor) {
    switch (valor) {
      case 1:
        return Alignment.center;

      case 3:
        return Alignment.centerRight;

      case 2:
      default:
        return Alignment.centerLeft;
    }
  }

  // =========================================================
  // FONTE
  // =========================================================

  String? _resolverFonte(String fonte) {
    final valor = fonte.trim().toLowerCase();

    if (valor == 'arial') {
      return 'Arial';
    }

    if (valor == 'courier') {
      return 'Courier New';
    }

    return null;
  }
}
