import 'pdv_parametro.dart';

class PdvConfig {
  final List<PdvParametro> parametros;

  PdvConfig({required this.parametros});

  PdvParametro? buscar({required int componente, required double id}) {
    try {
      return parametros.firstWhere(
        (parametro) => parametro.componente == componente && parametro.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  String? valor({required int componente, required double id}) {
    return buscar(componente: componente, id: id)?.parametro;
  }
}
