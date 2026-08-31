import '../models/pdv_message.dart';

class PdvMessageParser {
  PdvMessage? parse(String linha) {
    if (linha.isEmpty) {
      return null;
    }

    final comando = linha.split('|').first;

    return PdvMessage(
      tipo: _identificarTipo(comando),
      comando: comando,
      raw: linha,
    );
  }

  PdvMessageType _identificarTipo(String comando) {
    switch (comando) {
      case 'D':
        return PdvMessageType.digitacao;

      case 'E':
        return PdvMessageType.status;

      case 'M':
        return PdvMessageType.mensagem;

      case 'F':
        return PdvMessageType.funcao;

      case 'S':
        return PdvMessageType.sistema;

      case 'W':
        return PdvMessageType.impressora;

      case 'A':
        return PdvMessageType.alerta;

      case 'I':
        return PdvMessageType.informacao;

      case 'X':
        return PdvMessageType.interface;

      default:
        return PdvMessageType.desconhecido;
    }
  }
}
