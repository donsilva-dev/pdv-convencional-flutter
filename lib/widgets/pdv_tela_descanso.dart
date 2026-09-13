import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../controllers/pdv_descanso_controller.dart';

class PdvTelaDescanso extends StatefulWidget {
  const PdvTelaDescanso({super.key});

  @override
  State<PdvTelaDescanso> createState() => _PdvTelaDescansoState();
}

class _PdvTelaDescansoState extends State<PdvTelaDescanso> {
  late final Player _player;
  late final VideoController _videoController;
  late final FocusNode _focusNode;
  late final PdvDescansoController _descansoController;

  @override
  void initState() {
    super.initState();

    _descansoController = Get.find<PdvDescansoController>();

    _focusNode = FocusNode();

    _player = Player();

    _videoController = VideoController(_player);

    _abrirVideo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  Future<void> _abrirVideo() async {
    final caminho = _descansoController.caminhoVideo;

    if (caminho == null) {
      return;
    }

    final arquivo = File(caminho);

    if (!arquivo.existsSync()) {
      print('VIDEO DE DESCANSO NÃO ENCONTRADO: $caminho');
      return;
    }

    await _player.setPlaylistMode(PlaylistMode.loop);

    await _player.open(Media(caminho), play: true);
  }

  Future<void> _despertar() async {
    await _descansoController.despertar();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            _descansoController.despertar();
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _despertar,
          child: SizedBox.expand(
            child: Video(
              controller: _videoController,
              fit: BoxFit.cover,
              controls: NoVideoControls,
            ),
          ),
        ),
      ),
    );
  }
}
