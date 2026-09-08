// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// class PdvSocketService {
//   Socket? _socket;

//   final StreamController<String> _mensagensController =
//       StreamController<String>.broadcast();

//   final StreamController<bool> _conexaoController =
//       StreamController<bool>.broadcast();

//   Stream<String> get mensagens => _mensagensController.stream;

//   Stream<bool> get conexaoStream => _conexaoController.stream;

//   String _buffer = '';

//   bool _conectando = false;
//   bool _desconectando = false;

//   bool get conectado => _socket != null;
//   bool get conectando => _conectando;

//   Future<bool> conectar({required String host, required int port}) async {
//     if (_socket != null) {
//       return true;
//     }

//     if (_conectando) {
//       return false;
//     }

//     _conectando = true;
//     _desconectando = false;

//     print('Conectando ao PDV $host:$port...');

//     try {
//       final socket = await Socket.connect(
//         host,
//         port,
//         timeout: const Duration(seconds: 5),
//       );

//       _socket = socket;
//       _conectando = false;
//       _desconectando = false;

//       print('Conectado ao PDV!');

//       _emitirEstadoConexao(true);

//       socket.listen(
//         _receberDados,
//         onError: (erro) {
//           print('Erro no socket: $erro');

//           _tratarDesconexao();
//         },
//         onDone: () {
//           print('Socket encerrado pelo PDV.');

//           _tratarDesconexao();
//         },
//         cancelOnError: false,
//       );

//       return true;
//     } catch (e, stackTrace) {
//       _socket = null;
//       _conectando = false;
//       _desconectando = false;

//       print('Erro ao conectar no PDV: $e');

//       print(stackTrace);

//       _emitirEstadoConexao(false);

//       return false;
//     }
//   }

//   void _receberDados(List<int> data) {
//     try {
//       final texto = utf8.decode(data, allowMalformed: true);

//       _buffer += texto;

//       _processarBuffer();
//     } catch (e, stackTrace) {
//       print('Erro ao processar dados do PDV: $e');

//       print(stackTrace);
//     }
//   }

//   void _processarBuffer() {
//     while (true) {
//       final indice = _buffer.indexOf('\n');

//       if (indice == -1) {
//         return;
//       }

//       var mensagem = _buffer.substring(0, indice);

//       _buffer = _buffer.substring(indice + 1);

//       if (mensagem.endsWith('\r')) {
//         mensagem = mensagem.substring(0, mensagem.length - 1);
//       }

//       if (mensagem.isEmpty) {
//         continue;
//       }

//       print('<<< $mensagem');

//       if (!_mensagensController.isClosed) {
//         _mensagensController.add(mensagem);
//       }
//     }
//   }

//   Future<void> enviar(String mensagem) async {
//     final socket = _socket;

//     if (socket == null) {
//       print('Socket não conectado.');

//       return;
//     }

//     try {
//       print('>>> $mensagem');

//       socket.write('$mensagem\n');

//       await socket.flush();
//     } catch (e, stackTrace) {
//       print('Erro ao enviar mensagem: $e');

//       print(stackTrace);

//       _tratarDesconexao();
//     }
//   }

//   void _tratarDesconexao() {
//     if (_desconectando) {
//       return;
//     }

//     _desconectando = true;

//     final socket = _socket;

//     _socket = null;
//     _buffer = '';
//     _conectando = false;

//     try {
//       socket?.destroy();
//     } catch (e) {
//       print('Erro ao destruir socket: $e');
//     }

//     _emitirEstadoConexao(false);

//     _desconectando = false;
//   }

//   void _emitirEstadoConexao(bool estado) {
//     if (_conexaoController.isClosed) {
//       return;
//     }

//     _conexaoController.add(estado);
//   }

//   Future<void> desconectar() async {
//     if (_desconectando) {
//       return;
//     }

//     _desconectando = true;

//     final socket = _socket;

//     _socket = null;
//     _buffer = '';
//     _conectando = false;

//     if (socket != null) {
//       try {
//         await socket.flush();
//       } catch (e) {
//         print('Erro no flush ao desconectar: $e');
//       }

//       try {
//         socket.destroy();
//       } catch (e) {
//         print('Erro ao destruir socket: $e');
//       }
//     }

//     _emitirEstadoConexao(false);

//     _desconectando = false;

//     print('Socket desconectado.');
//   }

//   Future<void> dispose() async {
//     _desconectando = true;

//     final socket = _socket;

//     _socket = null;
//     _buffer = '';
//     _conectando = false;

//     try {
//       socket?.destroy();
//     } catch (e) {
//       print('Erro ao destruir socket no dispose: $e');
//     }

//     if (!_mensagensController.isClosed) {
//       await _mensagensController.close();
//     }

//     if (!_conexaoController.isClosed) {
//       await _conexaoController.close();
//     }

//     _desconectando = false;
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/app_config.dart';
import 'pdv_log_service.dart';

class PdvSocketService {
  final AppConfig config;
  final PdvLogService logService;

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

  PdvSocketService({required this.config, required this.logService});

  Future<bool> conectar() async {
    if (_socket != null) {
      return true;
    }

    if (_conectando) {
      return false;
    }

    _conectando = true;
    _desconectando = false;

    print('Conectando ao PDV ${config.host}:${config.porta}...');

    await logService.registrarConexao(
      'Conectando ao PDV ${config.host}:${config.porta}',
    );

    try {
      final socket = await Socket.connect(
        config.host,
        config.porta,
        timeout: const Duration(seconds: 5),
      );

      _socket = socket;

      _conectando = false;
      _desconectando = false;

      print('Conectado ao PDV!');

      await logService.registrarConexao(
        'Conectado ao PDV ${config.host}:${config.porta}',
      );

      _emitirEstadoConexao(true);

      socket.listen(
        _receberDados,
        onError: (erro) {
          print('Erro no socket: $erro');

          logService.registrarErro('Erro no socket', erro);

          _tratarDesconexao();
        },
        onDone: () {
          print('Socket encerrado pelo PDV.');

          logService.registrarConexao('Socket encerrado pelo PDV');

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

      await logService.registrarErro(
        'Falha ao conectar no PDV '
        '${config.host}:${config.porta}',
        e,
        stackTrace,
      );

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

      logService.registrarErro(
        'Erro ao processar dados recebidos do PDV',
        e,
        stackTrace,
      );
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

      // Recebido do PDV.
      logService.recebido(mensagem);

      if (!_mensagensController.isClosed) {
        _mensagensController.add(mensagem);
      }
    }
  }

  Future<void> enviar(String mensagem, {bool sensivel = false}) async {
    final socket = _socket;

    if (socket == null) {
      print('Socket não conectado.');

      await logService.registrarErro(
        'Tentativa de envio sem conexao'
        '${sensivel ? '' : ': $mensagem'}',
      );

      return;
    }

    try {
      print(sensivel ? '>>> ********' : '>>> $mensagem');

      if (sensivel) {
        await logService.enviado('********');
      } else {
        await logService.enviado(mensagem);
      }

      socket.write('$mensagem\n');

      await socket.flush();
    } catch (e, stackTrace) {
      print('Erro ao enviar mensagem: $e');

      print(stackTrace);

      await logService.registrarErro(
        'Erro ao enviar mensagem ao PDV',
        e,
        stackTrace,
      );

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

      logService.registrarErro('Erro ao destruir socket', e);
    }

    logService.registrarConexao('PDV desconectado');

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

        await logService.registrarErro('Erro no flush ao desconectar', e);
      }

      try {
        socket.destroy();
      } catch (e) {
        print('Erro ao destruir socket: $e');

        await logService.registrarErro('Erro ao destruir socket', e);
      }
    }

    await logService.registrarConexao('Socket desconectado pelo frontend');

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

      await logService.registrarErro('Erro ao destruir socket no dispose', e);
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
