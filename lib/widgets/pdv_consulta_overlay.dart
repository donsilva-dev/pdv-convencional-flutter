import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pdv_tela_controller.dart';
import '../models/pdv_label_config.dart';

class PdvConsultaOverlay extends StatelessWidget {
  const PdvConsultaOverlay({super.key});

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
          if (controller.status.value != 13) {
            return const SizedBox.shrink();
          }

          // =====================================================
          // ESTADO REATIVO DA CONSULTA
          // =====================================================

          controller.consultaCodigo.value;
          controller.consultaDescricao.value;
          controller.consultaQuantidade.value;
          controller.consultaValorUnitario.value;
          controller.consultaValorTotal.value;

          return LayoutBuilder(
            builder: (context, constraints) {
              final larguraTela = constraints.maxWidth;
              final alturaTela = constraints.maxHeight;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // =============================================
                  // 1203 - CÓDIGO DO PRODUTO
                  // =============================================
                  _buildLabel(
                    config: controller.labelCodigoProduto.value,
                    texto: controller.consultaCodigoFormatada,
                    larguraTela: larguraTela,
                    alturaTela: alturaTela,
                  ),

                  // =============================================
                  // 1204 - DESCRIÇÃO DO PRODUTO
                  // =============================================
                  _buildLabel(
                    config: controller.labelDescricaoProduto.value,
                    texto: controller.consultaDescricao.value,
                    larguraTela: larguraTela,
                    alturaTela: alturaTela,
                  ),

                  // =============================================
                  // 1205 - QUANTIDADE
                  // =============================================
                  _buildLabel(
                    config: controller.labelQuantidade.value,
                    texto: controller.consultaQuantidadeFormatada,
                    larguraTela: larguraTela,
                    alturaTela: alturaTela,
                  ),

                  // =============================================
                  // 1206 - PREÇO UNITÁRIO
                  // =============================================
                  _buildLabel(
                    config: controller.labelPrecoUnitario.value,
                    texto: controller.consultaValorUnitarioFormatado,
                    larguraTela: larguraTela,
                    alturaTela: alturaTela,
                  ),

                  // =============================================
                  // 1207 - PREÇO TOTAL
                  // =============================================
                  _buildLabel(
                    config: controller.labelPrecoTotal.value,
                    texto: controller.consultaValorTotalFormatado,
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

              // Fonte usa exatamente o valor vindo do XML
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
