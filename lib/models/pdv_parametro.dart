class PdvParametro {
  final int componente;
  final double id;
  final String parametro;

  const PdvParametro({
    required this.componente,
    required this.id,
    required this.parametro,
  });

  @override
  String toString() {
    return 'PdvParametro('
        'componente: $componente, '
        'id: $id, '
        'parametro: "$parametro"'
        ')';
  }
}
