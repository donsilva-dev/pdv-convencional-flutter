class PdvConexaoMensagem {
  final String titulo;
  final String mensagem;
  final String orientacao;
  final String animacao;

  const PdvConexaoMensagem({
    required this.titulo,
    required this.mensagem,
    required this.orientacao,
    required this.animacao,
  });

  factory PdvConexaoMensagem.fromJson(Map<String, dynamic> json) {
    return PdvConexaoMensagem(
      titulo: json['titulo']?.toString() ?? '',
      mensagem: json['mensagem']?.toString() ?? '',
      orientacao: json['orientacao']?.toString() ?? '',
      animacao: json['animacao']?.toString() ?? '',
    );
  }
}

class PdvConexaoConfig {
  final PdvConexaoMensagem offline;

  final PdvConexaoMensagem reconectando;

  const PdvConexaoConfig({required this.offline, required this.reconectando});

  factory PdvConexaoConfig.fromJson(Map<String, dynamic> json) {
    return PdvConexaoConfig(
      offline: PdvConexaoMensagem.fromJson(
        json['offline'] ?? <String, dynamic>{},
      ),
      reconectando: PdvConexaoMensagem.fromJson(
        json['reconectando'] ?? <String, dynamic>{},
      ),
    );
  }
}
