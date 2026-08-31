import 'dart:async';
import 'dart:convert';
import 'dart:io';

class PdvSocketService {
  Socket? _socket;

  final StreamController<String> _mensagensController =
      StreamController<String>.broadcast();

  final StreamController<bool> _conexaoController =
      StreamController<bool>.broadcast();

  Stream<String> get mensagens => _mensagensController.stream;

  Stream<bool> get conexaoStream => _conexaoController.stream;

  String _buffer = '';

  bool _conectando = false;
  bool _desconectando = false;

  bool get conectado => _socket != null;
  bool get conectando => _conectando;

  Future<bool> conectar({required String host, required int port}) async {
    if (_socket != null) {
      return true;
    }

    if (_conectando) {
      return false;
    }

    _conectando = true;
    _desconectando = false;

    print('Conectando ao PDV $host:$port...');

    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 5),
      );

      _socket = socket;
      _conectando = false;
      _desconectando = false;

      print('Conectado ao PDV!');

      _emitirEstadoConexao(true);

      socket.listen(
        _receberDados,
        onError: (erro) {
          print('Erro no socket: $erro');

          _tratarDesconexao();
        },
        onDone: () {
          print('Socket encerrado pelo PDV.');

          _tratarDesconexao();
        },
        cancelOnError: false,
      );

      return true;
    } catch (e, stackTrace) {
      _socket = null;
      _conectando = false;
      _desconectando = false;

      print('Erro ao conectar no PDV: $e');

      print(stackTrace);

      _emitirEstadoConexao(false);

      return false;
    }
  }

  void _receberDados(List<int> data) {
    try {
      final texto = utf8.decode(data, allowMalformed: true);

      _buffer += texto;

      _processarBuffer();
    } catch (e, stackTrace) {
      print('Erro ao processar dados do PDV: $e');

      print(stackTrace);
    }
  }

  void _processarBuffer() {
    while (true) {
      final indice = _buffer.indexOf('\n');

      if (indice == -1) {
        return;
      }

      var mensagem = _buffer.substring(0, indice);

      _buffer = _buffer.substring(indice + 1);

      if (mensagem.endsWith('\r')) {
        mensagem = mensagem.substring(0, mensagem.length - 1);
      }

      if (mensagem.isEmpty) {
        continue;
      }

      print('<<< $mensagem');

      if (!_mensagensController.isClosed) {
        _mensagensController.add(mensagem);
      }
    }
  }

  Future<void> enviar(String mensagem) async {
    final socket = _socket;

    if (socket == null) {
      print('Socket não conectado.');

      return;
    }

    try {
      print('>>> $mensagem');

      socket.write('$mensagem\n');

      await socket.flush();
    } catch (e, stackTrace) {
      print('Erro ao enviar mensagem: $e');

      print(stackTrace);

      _tratarDesconexao();
    }
  }

  void _tratarDesconexao() {
    if (_desconectando) {
      return;
    }

    _desconectando = true;

    final socket = _socket;

    _socket = null;
    _buffer = '';
    _conectando = false;

    try {
      socket?.destroy();
    } catch (e) {
      print('Erro ao destruir socket: $e');
    }

    _emitirEstadoConexao(false);

    _desconectando = false;
  }

  void _emitirEstadoConexao(bool estado) {
    if (_conexaoController.isClosed) {
      return;
    }

    _conexaoController.add(estado);
  }

  Future<void> desconectar() async {
    if (_desconectando) {
      return;
    }

    _desconectando = true;

    final socket = _socket;

    _socket = null;
    _buffer = '';
    _conectando = false;

    if (socket != null) {
      try {
        await socket.flush();
      } catch (e) {
        print('Erro no flush ao desconectar: $e');
      }

      try {
        socket.destroy();
      } catch (e) {
        print('Erro ao destruir socket: $e');
      }
    }

    _emitirEstadoConexao(false);

    _desconectando = false;

    print('Socket desconectado.');
  }

  Future<void> dispose() async {
    _desconectando = true;

    final socket = _socket;

    _socket = null;
    _buffer = '';
    _conectando = false;

    try {
      socket?.destroy();
    } catch (e) {
      print('Erro ao destruir socket no dispose: $e');
    }

    if (!_mensagensController.isClosed) {
      await _mensagensController.close();
    }

    if (!_conexaoController.isClosed) {
      await _conexaoController.close();
    }

    _desconectando = false;
  }
} 
