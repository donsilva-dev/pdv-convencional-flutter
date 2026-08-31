import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../controllers/pdv_tela_controller.dart';
import '../models/pdv_label_config.dart';

class PdvRecebimentoOverlay extends StatelessWidget {
  const PdvRecebimentoOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PdvTelaController>();

    return Positioned.fill(
      child: IgnorePointer(
        child: Obx(() {
          if (controller.status.value != 4) {
            return const SizedBox.shrink();
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // =============================================
              // 1116 - TOTAL DA COMPRA
              // =============================================
              _buildLabel(
                config: controller.labelTotalCompra.value,
                texto: controller.totalCompraFormatado,
              ),

              // =============================================
              // 1104 - VALOR PAGO
              // =============================================
              _buildLabel(
                config: controller.labelValorPago.value,
                texto: controller.valorPagoFormatado,
              ),

              // =============================================
              // 1105 - VALOR A PAGAR
              // =============================================
              _buildLabel(
                config: controller.labelValorAPagar.value,
                texto: controller.valorAPagarFormatado,
              ),

              // =============================================
              // 1106 - TROCO
              // =============================================
              _buildLabel(
                config: controller.labelTroco.value,
                texto: controller.trocoFormatado,
              ),
            ],
          );
        }),
      ),
    );
  }

  // =========================================================
  // LABEL PADRÃO DO RECEBIMENTO
  // =========================================================

  Widget _buildLabel({required PdvLabelConfig? config, required String texto}) {
    if (config == null || !config.visivel || texto.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: config.left,
      top: config.top,
      width: config.width,
      height: config.height,
      child: Align(
        alignment: _resolverAlinhamento(config.alinhamento),
        child: Text(
          texto,
          maxLines: 1,
          softWrap: false,
          overflow: config.redimensionamento == 1
              ? TextOverflow.clip
              : TextOverflow.visible,
          style: TextStyle(
            color: config.corFonte,
            fontFamily: _resolverFonte(config.fontFamily),
            fontSize: config.fontSize,
            fontWeight: config.bold ? FontWeight.bold : FontWeight.normal,
            fontStyle: config.italic ? FontStyle.italic : FontStyle.normal,
            height: 1.1,
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
