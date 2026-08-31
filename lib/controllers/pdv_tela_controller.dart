import 'package:get/get.dart';

import '../models/pdv_label_config.dart';
import '../models/pdv_parametro.dart';
import '../services/pdv_label_parser.dart';
import '../services/pdv_renderer_service.dart';
import '../widgets/pdv_draw_item.dart';

class PdvTelaController extends GetxController {
  final List<PdvParametro> parametros;

  late final PdvRendererService renderer;

  PdvTelaController(this.parametros);

  // ============================================================
  // ESTADO / IMAGEM
  // ============================================================

  final RxInt status = 0.obs;
  final RxString imagem = ''.obs;

  // ============================================================
  // DISPLAY INFERIOR
  // ============================================================

  final RxString displayEsquerda = ''.obs;
  final RxString displayDireita = ''.obs;

  final RxBool barraDisplayVisivel = true.obs;
  final RxBool displayCentralizado = false.obs;

  // ============================================================
  // FUNÇÃO
  // ============================================================

  final RxInt funcaoAtual = 0.obs;
  final RxString ultimaFuncao = ''.obs;

  final RxString subtipoFuncao = ''.obs;
  final RxInt codigoFuncao = 0.obs;

  // ============================================================
  // INTERFACE X|frmGeral
  // ============================================================

  final RxBool telaInterfaceAtiva = false.obs;

  final RxList<PdvDrawItem> elementosInterface = <PdvDrawItem>[].obs;

  double interfaceY = 0.0;
  double interfaceFontSize = 10.0;

  String interfaceFontName = 'Courier';

  bool interfaceBold = false;

  // ============================================================
  // LABELS - VENDA
  // ============================================================

  final Rxn<PdvLabelConfig> labelCodigoProduto = Rxn<PdvLabelConfig>();

  final Rxn<PdvLabelConfig> labelDescricaoProduto = Rxn<PdvLabelConfig>();

  final Rxn<PdvLabelConfig> labelQuantidade = Rxn<PdvLabelConfig>();

  final Rxn<PdvLabelConfig> labelPrecoUnitario = Rxn<PdvLabelConfig>();

  final Rxn<PdvLabelConfig> labelPrecoTotal = Rxn<PdvLabelConfig>();

  final Rxn<PdvLabelConfig> labelSubtotal = Rxn<PdvLabelConfig>();

  final Rxn<PdvLabelConfig> labelItensVendidos = Rxn<PdvLabelConfig>();

  // ============================================================
  // DADOS - VENDA
  // ============================================================

  final RxDouble codigoProdutoVenda = 0.0.obs;
  final RxString descricaoProdutoVenda = ''.obs;

  final RxDouble quantidadeVenda = 0.0.obs;
  final RxDouble valorUnitarioVenda = 0.0.obs;
  final RxDouble valorTotalVenda = 0.0.obs;
  final RxDouble subtotalVenda = 0.0.obs;

  final RxList<String> itensVendidos = <String>[].obs;

  // ============================================================
  // LABELS - RECEBIMENTO
  // ============================================================

  final Rxn<PdvLabelConfig> labelTotalCompra = Rxn<PdvLabelConfig>();

  final Rxn<PdvLabelConfig> labelValorPago = Rxn<PdvLabelConfig>();

  final Rxn<PdvLabelConfig> labelValorAPagar = Rxn<PdvLabelConfig>();

  final Rxn<PdvLabelConfig> labelTroco = Rxn<PdvLabelConfig>();

  // ============================================================
  // DADOS - RECEBIMENTO
  // ============================================================

  final RxDouble totalCompra = 0.0.obs;
  final RxDouble valorPago = 0.0.obs;
  final RxDouble valorAPagar = 0.0.obs;
  final RxDouble troco = 0.0.obs;

  final RxList<String> dadosRecebimento = <String>[].obs;

  // ============================================================
  // INICIALIZAÇÃO
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    renderer = PdvRendererService(parametros);

    _carregarTelaInicial();
    _carregarLabelsVenda();
    _carregarLabelsRecebimento();
  }

  // ============================================================
  // GETTERS FORMATADOS - VENDA
  // ============================================================
  String get codigoProdutoVendaFormatada {
    return _formatarQuantidade(codigoProdutoVenda.value);
  }

  String get quantidadeVendaFormatada {
    return _formatarQuantidade(quantidadeVenda.value);
  }

  String get valorUnitarioFormatado {
    return _formatarMoeda(valorUnitarioVenda.value);
  }

  String get valorTotalFormatado {
    return _formatarMoeda(valorTotalVenda.value);
  }

  String get subtotalFormatado {
    return _formatarMoeda(subtotalVenda.value);
  }

  // ============================================================
  // GETTERS FORMATADOS - RECEBIMENTO
  // ============================================================

  String get totalCompraFormatado {
    return _formatarMoeda(totalCompra.value);
  }

  String get valorPagoFormatado {
    return _formatarMoeda(valorPago.value);
  }

  String get valorAPagarFormatado {
    return _formatarMoeda(valorAPagar.value);
  }

  String get trocoFormatado {
    return _formatarMoeda(troco.value);
  }

  // ============================================================
  // CARREGAMENTO DAS LABELS - VENDA
  // ============================================================

  void _carregarLabelsVenda() {
    labelCodigoProduto.value = _carregarLabel(1203);

    labelDescricaoProduto.value = _carregarLabel(1204);

    labelQuantidade.value = _carregarLabel(1205);

    labelPrecoUnitario.value = _carregarLabel(1206);

    labelPrecoTotal.value = _carregarLabel(1207);

    labelSubtotal.value = _carregarLabel(1208);

    labelItensVendidos.value = _carregarLabel(1210);
  }

  // ============================================================
  // CARREGAMENTO DAS LABELS - RECEBIMENTO
  // ============================================================

  void _carregarLabelsRecebimento() {
    // TOTAL DA COMPRA
    labelTotalCompra.value = _carregarLabel(1116);

    // VALOR PAGO
    labelValorPago.value = _carregarLabel(1104);

    // VALOR A PAGAR
    labelValorAPagar.value = _carregarLabel(1105);

    // TROCO
    labelTroco.value = _carregarLabel(1106);
  }

  // ============================================================
  // CARREGAMENTO GENÉRICO DE LABEL
  // ============================================================

  PdvLabelConfig? _carregarLabel(int id) {
    final parametro = renderer.buscar(id);

    if (parametro == null || parametro.trim().isEmpty) {
      print('LABEL $id NÃO ENCONTRADA NO XML');

      return null;
    }

    final parser = PdvLabelParser();

    return parser.parse(id: id, parametro: parametro);
  }

  // ============================================================
  // VENDA - ATUALIZAR ITEM
  // ============================================================

  void atualizarItemVenda({
    required double codigo,
    required String descricao,
    required double quantidade,
    required double valorUnitario,
    required double valorTotal,
  }) {
    codigoProdutoVenda.value = codigo;

    descricaoProdutoVenda.value = descricao;

    quantidadeVenda.value = quantidade;

    valorUnitarioVenda.value = valorUnitario;

    valorTotalVenda.value = valorTotal;

    subtotalVenda.value += valorTotal;

    final quantidadeTexto = _formatarQuantidade(quantidade);

    final item = '$quantidadeTexto X $descricao';

    itensVendidos.add(item);

    print('======= ITEM VENDA =======');

    print('CÓDIGO: $codigo');

    print('DESCRIÇÃO: $descricao');

    print('QUANTIDADE: $quantidadeTexto');

    print('UNITÁRIO: ${_formatarMoeda(valorUnitario)}');

    print('TOTAL ITEM: ${_formatarMoeda(valorTotal)}');

    print('SUBTOTAL: $subtotalFormatado');

    print('==========================');
  }

  // ============================================================
  // VENDA - ADICIONAR ITEM MANUALMENTE
  // ============================================================

  void adicionarItemVendido({
    required String quantidade,
    required String descricao,
    required String valorTotal,
  }) {
    final linha = '$quantidade X $descricao   $valorTotal';

    itensVendidos.add(linha);
  }

  // ============================================================
  // VENDA - LIMPAR
  // ============================================================

  void limparVenda() {
    codigoProdutoVenda.value = 0.0;
    descricaoProdutoVenda.value = '';

    quantidadeVenda.value = 0.0;
    valorUnitarioVenda.value = 0.0;
    valorTotalVenda.value = 0.0;
    subtotalVenda.value = 0.0;

    itensVendidos.clear();

    print('======= VENDA LIMPA =======');

    print('QUANTIDADE: $quantidadeVendaFormatada');

    print('VALOR UNITÁRIO: $valorUnitarioFormatado');

    print('VALOR TOTAL: $valorTotalFormatado');

    print('SUBTOTAL: $subtotalFormatado');

    print('===========================');
  }

  // ============================================================
  // RECEBIMENTO
  // ============================================================

  void atualizarRecebimento(List<String> partes) {
    dadosRecebimento.assignAll(partes.map((e) => e.trim()));

    // I|10|127.95|...|70|57.95...
    //
    // [2] = TOTAL DA COMPRA
    // [6] = VALOR PAGO
    // [7] = VALOR A PAGAR

    totalCompra.value = _campoRecebimentoDouble(2);

    valorPago.value = _campoRecebimentoDouble(6);

    valorAPagar.value = _campoRecebimentoDouble(7);
    troco.value = _campoRecebimentoDouble(8);

    print('======= RECEBIMENTO =======');

    print('TOTAL: $totalCompraFormatado');

    print('PAGO: $valorPagoFormatado');

    print('A PAGAR: $valorAPagarFormatado');

    print('TROCO: $trocoFormatado');

    print('===========================');
  }

  double _campoRecebimentoDouble(int index) {
    if (index < 0 || index >= dadosRecebimento.length) {
      return 0.0;
    }

    final valor = dadosRecebimento[index].trim().replaceAll(',', '.');

    return double.tryParse(valor) ?? 0.0;
  }

  // ============================================================
  // TELA INICIAL
  // ============================================================

  void _carregarTelaInicial() {
    final imagemInicial = renderer.imagemPorStatus(status.value);

    if (_imagemValida(imagemInicial)) {
      imagem.value = imagemInicial!;
    }
  }

  // ============================================================
  // E| STATUS
  // ============================================================

  void atualizarStatus(int novoStatus) {
    status.value = novoStatus;

    if (novoStatus == 2 && telaInterfaceAtiva.value) {
      fecharInterface();
    }

    final novaImagem = renderer.imagemPorStatus(novoStatus);

    if (_imagemValida(novaImagem)) {
      imagem.value = novaImagem!;
    }

    barraDisplayVisivel.value = true;

    print('STATUS: $novoStatus');

    print('IMAGEM: ${imagem.value}');
  }

  // ============================================================
  // FUNÇÃO ENVIADA
  // ============================================================

  void prepararFuncao(int codigo) {
    funcaoAtual.value = codigo;

    barraDisplayVisivel.value = true;
  }

  // ============================================================
  // D| DISPLAY
  // ============================================================

  void atualizarDisplay({required String esquerda, String direita = ''}) {
    if (_ehItemVenda(esquerda: esquerda, direita: direita)) {
      if (_processarItemDisplay(esquerda: esquerda, direita: direita)) {
        return;
      }
    }

    if (_ehMensagemAtualizaEmbalagem(esquerda: esquerda, direita: direita)) {
      _mostrarDisplayCentralizado(
        '$esquerda $direita'.replaceAll(RegExp(r'\s+'), ' ').trim(),
      );

      return;
    }

    _mostrarDisplayNormal(esquerda: esquerda, direita: direita);
  }

  // ============================================================
  // DISPLAY - ITEM VENDA
  // ============================================================

  bool _ehItemVenda({required String esquerda, required String direita}) {
    return status.value == 3 && esquerda.contains(' X ') && direita.isNotEmpty;
  }

  bool _processarItemDisplay({
    required String esquerda,
    required String direita,
  }) {
    final match = RegExp(r'^(.*?)\s+(\d+[,.]\d{2})\s*$').firstMatch(direita);

    if (match == null) {
      return false;
    }

    final complementoNome = match.group(1)?.trim() ?? '';

    final valor = match.group(2)?.trim() ?? '';

    final nomeCompleto = '$esquerda $complementoNome'
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    displayEsquerda.value = nomeCompleto;

    displayDireita.value = valor;

    displayCentralizado.value = false;

    barraDisplayVisivel.value = true;

    return true;
  }

  // ============================================================
  // DISPLAY - MENSAGEM ESPECIAL
  // ============================================================

  bool _ehMensagemAtualizaEmbalagem({
    required String esquerda,
    required String direita,
  }) {
    return esquerda.trim() == 'Atualiza embalagem a' &&
        direita.trim() == 'tacado';
  }

  // ============================================================
  // DISPLAY NORMAL
  // ============================================================

  void _mostrarDisplayNormal({
    required String esquerda,
    required String direita,
  }) {
    displayEsquerda.value = esquerda;

    displayDireita.value = direita;

    displayCentralizado.value = false;

    barraDisplayVisivel.value = true;
  }

  // ============================================================
  // DISPLAY CENTRALIZADO
  // ============================================================

  void _mostrarDisplayCentralizado(String texto) {
    displayEsquerda.value = texto;

    displayDireita.value = '';

    displayCentralizado.value = true;

    barraDisplayVisivel.value = true;
  }

  // ============================================================
  // F| FUNÇÃO
  // ============================================================

  void processarFuncao({required String subtipo, required int codigo}) {
    subtipoFuncao.value = subtipo;

    codigoFuncao.value = codigo;

    ultimaFuncao.value = '$subtipo|$codigo';

    funcaoAtual.value = codigo;

    barraDisplayVisivel.value = true;

    // Função 198:
    // somente F|I|198 abre a interface.

    if (codigo == 198 && subtipo.toUpperCase() == 'I') {
      abrirTelaDominio();
    }

    print(
      'TELA RECEBEU FUNÇÃO: '
      '$subtipo|$codigo',
    );
  }

  // ============================================================
  // FUNÇÃO 198
  // ============================================================

  void abrirTelaDominio() {
    final imagemDominio = renderer.buscar(1301);

    if (_imagemValida(imagemDominio)) {
      imagem.value = imagemDominio!;
    }

    telaInterfaceAtiva.value = true;

    elementosInterface.clear();

    _resetarEstadoInterface();

    print('TELA DOMÍNIO ABERTA');

    print(
      'IMAGEM DOMÍNIO: '
      '${imagem.value}',
    );
  }

  // ============================================================
  // X| CLS
  // ============================================================

  void limparInterface() {
    elementosInterface.clear();

    // Não desativa a interface.
    // A função 198 envia CLS antes dos PRINT.

    print('INTERFACE LIMPA');
  }

  // ============================================================
  // X| Y
  // ============================================================

  void alterarYInterface(double y) {
    interfaceY = y;

    print(
      'INTERFACE Y: '
      '$interfaceY',
    );
  }

  // ============================================================
  // X| FONTSIZE
  // ============================================================

  void alterarTamanhoFonteInterface(double tamanho) {
    interfaceFontSize = tamanho;

    print(
      'INTERFACE FONT SIZE: '
      '$interfaceFontSize',
    );
  }

  // ============================================================
  // X| FONTNAME
  // ============================================================

  void alterarFonteInterface(String fonte) {
    interfaceFontName = fonte;

    print(
      'INTERFACE FONT: '
      '$interfaceFontName',
    );
  }

  // ============================================================
  // X| FONTBOLD
  // ============================================================

  void alterarBoldInterface(bool valor) {
    interfaceBold = valor;

    print(
      'INTERFACE BOLD: '
      '$interfaceBold',
    );
  }

  // ============================================================
  // X| PRINT
  // ============================================================

  void imprimirInterface(String texto) {
    if (!telaInterfaceAtiva.value) {
      return;
    }

    elementosInterface.add(
      PdvDrawItem(
        texto: texto,
        y: interfaceY,
        fontSize: interfaceFontSize,
        fontName: interfaceFontName,
        bold: interfaceBold,
      ),
    );

    print(
      'INTERFACE PRINT '
      'Y=$interfaceY: '
      '"$texto"',
    );

    // Mantemos exatamente o avanço que
    // já estava funcionando na função 198.
    interfaceY += interfaceFontSize + 6;
  }

  // ============================================================
  // FECHAR INTERFACE
  // ============================================================

  void fecharInterface() {
    telaInterfaceAtiva.value = false;

    elementosInterface.clear();

    _resetarEstadoInterface();
  }

  void _resetarEstadoInterface() {
    interfaceY = 0.0;
    interfaceFontSize = 10.0;
    interfaceFontName = 'Courier';
    interfaceBold = false;
  }

  // ============================================================
  // LIMPAR DISPLAY
  // ============================================================

  void limparBarraDisplay() {
    displayEsquerda.value = '';

    displayDireita.value = '';

    displayCentralizado.value = false;

    barraDisplayVisivel.value = true;

    funcaoAtual.value = 0;
  }

  // ============================================================
  // FORMATAÇÃO
  // ============================================================

  String _formatarMoeda(double valor) {
    return valor.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _formatarQuantidade(double valor) {
    // Exemplo:
    // 1.0   -> 1
    // 2.0   -> 2
    // 0.5   -> 0,5
    // 1.250 -> 1,25

    if (valor == valor.truncateToDouble()) {
      return valor.toStringAsFixed(0);
    }

    var texto = valor.toStringAsFixed(3);

    texto = texto.replaceFirst(RegExp(r'0+$'), '');

    texto = texto.replaceFirst(RegExp(r'\.$'), '');

    return texto.replaceAll('.', ',');
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool _imagemValida(String? nomeImagem) {
    return nomeImagem != null && nomeImagem.isNotEmpty;
  }
}
