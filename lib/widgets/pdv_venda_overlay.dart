import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pdv_tela_controller.dart';
import '../models/pdv_label_config.dart';

class PdvVendaOverlay extends StatelessWidget {
  const PdvVendaOverlay({super.key});

  static const double larguraBasePdv = 9000.0;
  static const double alturaBasePdv = 7000.0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PdvTelaController>();

    return Positioned.fill(
      child: IgnorePointer(
        child: Obx(() {
          if (controller.status.value != 3) {
            return const SizedBox.shrink();
          }

          // =========================================================
          // ESTADO REATIVO DA VENDA
          // =========================================================
          //
          // Lemos explicitamente os Rx utilizados pela tela.
          // Assim, qualquer I|02 recebido durante a venda
          // provoca imediatamente a reconstrução do overlay.
          // =========================================================

          controller.codigoProdutoVenda.value;
          controller.descricaoProdutoVenda.value;
          controller.quantidadeVenda.value;
          controller.valorUnitarioVenda.value;
          controller.valorTotalVenda.value;
          controller.subtotalVenda.value;
          controller.itensVendidos.length;

          return LayoutBuilder(
            builder: (context, constraints) {
              final larguraTela = constraints.maxWidth;
              final alturaTela = constraints.maxHeight;

              return Stack(
                fit: StackFit.expand,
                children: [
                  _buildLabel(
                    config: controller.labelCodigoProduto.value,
                    texto: controller.codigoProdutoVendaFormatada,
                    larguraTela: larguraTela,
                    alturaTela: alturaTela,
                  ),

                  _buildLabel(
                    config: controller.labelDescricaoProduto.value,
                    texto: controller.descricaoProdutoVenda.value,
                    larguraTela: larguraTela,
                    alturaTela: alturaTela,
                  ),

                  _buildLabel(
                    config: controller.labelQuantidade.value,
                    texto: controller.quantidadeVendaFormatada,
                    larguraTela: larguraTela,
                    alturaTela: alturaTela,
                  ),

                  _buildLabel(
                    config: controller.labelPrecoUnitario.value,
                    texto: controller.valorUnitarioFormatado,
                    larguraTela: larguraTela,
                    alturaTela: alturaTela,
                  ),

                  _buildLabel(
                    config: controller.labelPrecoTotal.value,
                    texto: controller.valorTotalFormatado,
                    larguraTela: larguraTela,
                    alturaTela: alturaTela,
                  ),

                  _buildLabel(
                    config: controller.labelSubtotal.value,
                    texto: controller.subtotalFormatado,
                    larguraTela: larguraTela,
                    alturaTela: alturaTela,
                  ),

                  _buildItensVendidos(
                    config: controller.labelItensVendidos.value,
                    itens: controller.itensVendidos,
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
  // 1210 - ITENS VENDIDOS
  // =========================================================

  Widget _buildItensVendidos({
    required PdvLabelConfig? config,
    required List<String> itens,
    required double larguraTela,
    required double alturaTela,
  }) {
    if (config == null || !config.visivel || itens.isEmpty) {
      return const SizedBox.shrink();
    }

    final scaleX = _scaleX(larguraTela);
    final scaleY = _scaleY(alturaTela);

    final texto = itens.join('\n');

    return Positioned(
      left: config.left * scaleX,
      top: config.top * scaleY,
      width: config.width * scaleX,
      height: config.height * scaleY,
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

              // IMPORTANTE:
              // fontSize vem diretamente do XML.
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
            maxLines: _maxLines(config),
            softWrap: true,
            overflow: TextOverflow.clip,
            style: TextStyle(
              color: config.corFonte,
              fontFamily: _resolverFonte(config.fontFamily),

              // IMPORTANTE:
              // não escalamos o tamanho da fonte.
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
