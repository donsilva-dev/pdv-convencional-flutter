import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pdv_controller.dart';

class PdvConexaoOverlay extends StatelessWidget {
  const PdvConexaoOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PdvController>();

    return Obx(() {
      // Ainda não terminou a primeira tentativa de conexão.
      if (!controller.conexaoInicializada.value) {
        return const SizedBox.shrink();
      }

      // Está conectado: não mostra absolutamente nada.
      if (controller.conectado.value) {
        return const SizedBox.shrink();
      }

      // Só chega aqui quando realmente está offline.
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 120, color: Colors.red),

                    const SizedBox(height: 30),

                    const Text(
                      'PDV FORA DE COMUNICAÇÃO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Não foi possível comunicar com o sistema do caixa.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Aguarde enquanto tentamos restabelecer a conexão.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 17, color: Colors.black54),
                    ),

                    const SizedBox(height: 28),

                    if (controller.tentativaReconexao.value > 0)
                      Text(
                        'Tentativa de reconexão '
                        '${controller.tentativaReconexao.value}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
