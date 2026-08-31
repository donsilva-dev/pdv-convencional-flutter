import 'package:flutter/material.dart';

class PdvLabelConfig {
  final int id;
  final Color corFonte;
  final bool visivel;
  final double left;
  final double top;
  final double height;
  final double width;
  final String fontFamily;
  final double fontSize;
  final bool italic;
  final bool bold;
  final Color? corFundo;
  final int redimensionamento;
  final int alinhamento;
  final int borda;
  final String conteudo;

  const PdvLabelConfig({
    required this.id,
    required this.corFonte,
    required this.visivel,
    required this.left,
    required this.top,
    required this.height,
    required this.width,
    required this.fontFamily,
    required this.fontSize,
    required this.italic,
    required this.bold,
    required this.corFundo,
    required this.redimensionamento,
    required this.alinhamento,
    required this.borda,
    required this.conteudo,
  });
}
