import '../models/pdv_parametro.dart';

class PdvRendererService {
  final List<PdvParametro> parametros;

  int _componenteAtual = 0;

  PdvRendererService(this.parametros);

  int get componenteAtual => _componenteAtual;

  void definirComponente(int componente) {
    _componenteAtual = componente;

    print('RENDERER - COMPONENTE ATUAL: $_componenteAtual');
  }

  String? buscar(int id, {int? componente}) {
    final componenteBusca = componente ?? _componenteAtual;

    // Primeiro procura exatamente COMPONENTE + ID.
    try {
      return parametros
          .firstWhere(
            (p) => p.componente == componenteBusca && p.id.toInt() == id,
          )
          .parametro;
    } catch (_) {
      // Continua para o componente padrão.
    }

    // Caso não exista o parâmetro no componente específico,
    // procura no componente 0.
    if (componenteBusca != 0) {
      try {
        return parametros
            .firstWhere((p) => p.componente == 0 && p.id.toInt() == id)
            .parametro;
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  // ============================================================
  // POSIÇÃO DO PARÂMETRO
  //
  // Exemplo:
  //
  // estado1.bmp;estado2.bmp;estado3.bmp
  //
  // posição 0 -> estado1.bmp
  // posição 1 -> estado2.bmp
  // posição 2 -> estado3.bmp
  // ============================================================

  String? buscarPosicao(int id, int posicao, {int? componente}) {
    final parametro = buscar(id, componente: componente);

    if (parametro == null) {
      return null;
    }

    final posicoes = parametro.split(';');

    if (posicao < 0 || posicao >= posicoes.length) {
      return null;
    }

    final valor = posicoes[posicao].trim();

    if (valor.isEmpty) {
      return null;
    }

    return valor;
  }

  String? imagemPorStatus(int status) {
    switch (status) {
      case 0:
        // ABERTURA
        return buscarPosicao(1001, 0);

      case 1:
        // FECHADO PARCIAL
        return buscarPosicao(1001, 0);

      case 2:
        // DISPONÍVEL
        return buscarPosicao(1001, 0);

      case 3:
        // VENDA
        return buscarPosicao(1200, 0);

      case 4:
        // RECEBIMENTO
        return buscarPosicao(1100, 0)?.split(',').first.trim();

      case 13:
        // CONSULTA
        return buscarPosicao(1215, 0);

      default:
        return buscarPosicao(1001, 0);
    }
  }

  int tempoTela() {
    final valor = buscarPosicao(1006, 0);

    return int.tryParse(valor ?? '') ?? 15;
  }
}
