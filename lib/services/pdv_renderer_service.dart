import '../models/pdv_parametro.dart';

class PdvRendererService {
  final List<PdvParametro> parametros;

  PdvRendererService(this.parametros);

  String? buscar(int id, {int componente = 0}) {
    try {
      return parametros
          .firstWhere((p) => p.componente == componente && p.id.toInt() == id)
          .parametro;
    } catch (_) {
      return null;
    }
  }

  String? imagemPorStatus(int status) {
    switch (status) {
      case 0:
        // ABERTURA
        return buscar(1001);

      case 1:
        // FECHADO PARCIAL
        return buscar(1001);

      case 2:
        // DISPONÍVEL
        return buscar(1001);

      case 3:
        // VENDA
        return buscar(1200);

      case 4:
        // RECEBIMENTO
        return buscar(1100)?.split(',').first.trim();

      case 13:
        return buscar(1215);

      default:
        return buscar(1001);
    }
  }

  int tempoTela() {
    final valor = buscar(1006);

    return int.tryParse(valor ?? '') ?? 15;
  }
}
