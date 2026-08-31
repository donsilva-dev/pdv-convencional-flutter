import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pdv_tela_controller.dart';
import '../models/pdv_label_config.dart';

class PdvVendaOverlay extends StatelessWidget {
  const PdvVendaOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PdvTelaController>();

    return Positioned.fill(
      child: IgnorePointer(
        child: Obx(() {
          if (controller.status.value != 3) {
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
                texto: controller.codigoProdutoVendaFormatada,
              ),

              // =============================================
              // 1204 - DESCRIÇÃO DO PRODUTO
              // =============================================
              _buildLabel(
                config: controller.labelDescricaoProduto.value,
                texto: controller.descricaoProdutoVenda.value,
              ),

              // =============================================
              // 1205 - QUANTIDADE
              // =============================================
              _buildLabel(
                config: controller.labelQuantidade.value,
                texto: controller.quantidadeVendaFormatada,
              ),

              // =============================================
              // 1206 - PREÇO UNITÁRIO
              // =============================================
              _buildLabel(
                config: controller.labelPrecoUnitario.value,
                texto: controller.valorUnitarioFormatado,
              ),

              // =============================================
              // 1207 - PREÇO TOTAL
              // =============================================
              _buildLabel(
                config: controller.labelPrecoTotal.value,
                texto: controller.valorTotalFormatado,
              ),

              // =============================================
              // 1208 - SUBTOTAL
              // =============================================
              _buildLabel(
                config: controller.labelSubtotal.value,
                texto: controller.subtotalFormatado,
              ),

              // =============================================
              // 1210 - ITENS VENDIDOS
              // =============================================
              _buildItensVendidos(
                config: controller.labelItensVendidos.value,
                itens: controller.itensVendidos,
              ),
            ],
          );
        }),
      ),
    );
  }

  // =========================================================
  // ITENS VENDIDOS - 1210
  // =========================================================

  Widget _buildItensVendidos({
    required PdvLabelConfig? config,
    required List<String> itens,
  }) {
    if (config == null || !config.visivel || itens.isEmpty) {
      return const SizedBox.shrink();
    }

    final texto = itens.join('\n');

    return Positioned(
      left: config.left,
      top: config.top,
      width: config.width,
      height: config.height,
      child: ClipRect(
        child: Align(
          alignment: Alignment.topLeft,
          child: Text(
            texto,
            softWrap: false,
            overflow: TextOverflow.clip,
            style: TextStyle(
              color: config.corFonte,
              fontFamily: _resolverFonte(config.fontFamily),
              fontSize: config.fontSize,
              fontWeight: config.bold ? FontWeight.bold : FontWeight.normal,
              fontStyle: config.italic ? FontStyle.italic : FontStyle.normal,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // LABEL PADRÃO
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
    // Descrição pode ocupar mais de uma linha.
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
