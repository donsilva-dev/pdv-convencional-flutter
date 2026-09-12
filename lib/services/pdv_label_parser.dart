import 'package:flutter/material.dart';
import 'package:pdv_convencional/models/pdv_label_config.dart';

class PdvLabelParser {
  PdvLabelConfig? parse({required int id, required String parametro}) {
    if (parametro.trim().isEmpty) {
      return null;
    }

    final partes = parametro.split(',');

    if (partes.length < 8) {
      print('Parâmetro $id inválido para label: $parametro');
      return null;
    }

    return PdvLabelConfig(
      id: id,

      // 1ª posição - cor da fonte
      corFonte: _parseCor(partes[0]),

      // 2ª posição - visibilidade
      visivel: _parseBool(partes[1]),

      // 3ª posição - distância da esquerda
      left: _parseNumero(partes, 2),

      // 4ª posição - distância do topo
      top: _parseNumero(partes, 3),

      // 5ª posição - altura
      height: _parseNumero(partes, 4),

      // 6ª posição - largura
      width: _parseNumero(partes, 5),

      // 7ª posição - fonte
      fontFamily: _texto(partes, 6, 'Arial'),

      // 8ª posição - tamanho da fonte
      fontSize: _parseNumero(partes, 7),

      // 9ª posição - itálico
      italic: _parseBool(_parte(partes, 8)),

      // 10ª posição - negrito
      bold: _parseBool(_parte(partes, 9)),

      // 12ª posição - cor de fundo
      corFundo: partes.length > 11 ? _parseCorOpcional(partes[11]) : null,

      // Campos adicionais existentes em alguns parâmetros
      redimensionamento: _parseInteiro(partes, 12),
      alinhamento: _parseInteiro(partes, 13),
      borda: _parseInteiro(partes, 14),
      conteudo: _parte(partes, 15),
    );
  }

  bool _parseBool(String valor) {
    final v = valor.trim().toUpperCase();

    return v == 'S' || v == 'SIM' || v == 'TRUE' || v == '1';
  }

  double _parseNumero(List<String> partes, int indice) {
    if (indice >= partes.length) {
      return 0;
    }

    final valor = partes[indice].trim();

    return double.tryParse(valor) ?? 0;
  }

  int _parseInteiro(List<String> partes, int indice) {
    if (indice >= partes.length) {
      return 0;
    }

    return int.tryParse(partes[indice].trim()) ?? 0;
  }

  String _parte(List<String> partes, int indice) {
    if (indice >= partes.length) {
      return '';
    }

    return partes[indice].trim();
  }

  String _texto(List<String> partes, int indice, String padrao) {
    final valor = _parte(partes, indice);

    return valor.isEmpty ? padrao : valor;
  }

  Color _parseCor(String valor) {
    final numero = int.tryParse(valor.trim());

    if (numero == null) {
      return Colors.black;
    }

    return _converterTColor(numero);
  }

  Color? _parseCorOpcional(String valor) {
    final texto = valor.trim();

    if (texto.isEmpty ||
        texto.toUpperCase() == 'N' ||
        texto.toUpperCase() == 'NAO') {
      return null;
    }

    final numero = int.tryParse(texto);

    if (numero == null) {
      return null;
    }

    return _converterTColor(numero);
  }

  Color _converterTColor(int valor) {
    final blue = (valor >> 16) & 0xFF;
    final green = (valor >> 8) & 0xFF;
    final red = valor & 0xFF;

    return Color.fromARGB(255, red, green, blue);
  }
}
