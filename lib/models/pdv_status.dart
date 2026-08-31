enum PdvStatus {
  abertura(0),
  fechadoParcial(1),
  disponivel(2),
  venda(3),
  recebimento(4),
  pausa(5),
  fechado(6),
  retirada(7),
  reabastecimento(8),
  atualizandoLote(9),
  carga(10),
  plano(11),
  calculadora(12),
  consulta(13),
  pagamento(14),
  desconhecido(-1);

  final int codigo;

  const PdvStatus(this.codigo);

  static PdvStatus fromCodigo(int codigo) {
    return PdvStatus.values.firstWhere(
      (status) => status.codigo == codigo,
      orElse: () => PdvStatus.desconhecido,
    );
  }
}
