import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pdv_tela_controller.dart';
import '../models/pdv_label_config.dart';

class PdvConsultaOverlay extends StatelessWidget {
  const PdvConsultaOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PdvTelaController>();

    return Positioned.fill(
      child: IgnorePointer(
        child: Obx(() {
          if (controller.status.value != 13) {
            return const SizedBox.shrink();
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // =============================================
              // 1203 - CÓDIGO DO PRODUTO
              // =============================================
              _buildLabel(
                config: controller.labelCodigoProduto.value,
                texto: controller.consultaCodigoFormatada,
              ),

              // =============================================
              // 1204 - DESCRIÇÃO DO PRODUTO
              // =============================================
              _buildLabel(
                config: controller.labelDescricaoProduto.value,
                texto: controller.consultaDescricao.value,
              ),

              // =============================================
              // 1205 - QUANTIDADE
              // =============================================
              _buildLabel(
                config: controller.labelQuantidade.value,
                texto: controller.consultaQuantidadeFormatada,
              ),

              // =============================================
              // 1206 - PREÇO UNITÁRIO
              // =============================================
              _buildLabel(
                config: controller.labelPrecoUnitario.value,
                texto: controller.consultaValorUnitarioFormatado,
              ),

              // =============================================
              // 1207 - PREÇO TOTAL
              // =============================================
              _buildLabel(
                config: controller.labelPrecoTotal.value,
                texto: controller.consultaValorTotalFormatado,
              ),
            ],
          );
        }),
      ),
    );
  }

  // =========================================================
  // LABEL PADRÃO
  // MESMA REGRA DA VENDA
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
          maxLines: _maxLines(config),
          softWrap: true,
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
  // QUANTIDADE DE LINHAS
  // =========================================================
  int? _maxLines(PdvLabelConfig config) {
    if (config.id == 1204) {
      return null;
    }

    return 1;
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
