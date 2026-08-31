enum PdvMessageType {
  digitacao,
  status,
  mensagem,
  funcao,
  sistema,
  impressora,
  alerta,
  informacao,
  interface,
  desconhecido,
}

class PdvMessage {
  final PdvMessageType tipo;

  /// Primeiro identificador da mensagem.
  /// Ex: D, E, S, F...
  final String comando;

  /// Mensagem exatamente como recebida do PDV.
  final String raw;

  const PdvMessage({
    required this.tipo,
    required this.comando,
    required this.raw,
  });

  @override
  String toString() {
    return 'PdvMessage(tipo: $tipo, comando: $comando, raw: "$raw")';
  }
}
