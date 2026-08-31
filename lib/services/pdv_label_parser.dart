import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pdv_convencional/models/pdv_label_config.dart';

class PdvLabelParser {
  static const double escalaX = 10.0;
  static const double escalaY = 8.0;

  static const double escalaWidth = 7.5;
  static const double escalaHeight = 7.5;

  static const double offsetY = 90.0;

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
      corFonte: _parseCor(partes[0]),
      visivel: _parseBool(partes[1]),

      left: _parseNumero(partes, 2) / escalaX,
      top: (_parseNumero(partes, 3) / escalaY) - offsetY,
      height: _parseNumero(partes, 4) / escalaHeight,
      width: _parseNumero(partes, 5) / escalaWidth,

      fontFamily: _texto(partes, 6, 'Arial'),

      fontSize: _parseNumero(partes, 7),

      italic: _parseBool(_parte(partes, 8)),

      bold: _parseBool(_parte(partes, 9)),

      corFundo: partes.length > 11 ? _parseCorOpcional(partes[11]) : null,

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

    return double.tryParse(partes[indice].trim()) ?? 0;
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

    if (texto.isEmpty || texto == 'N') {
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
