import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/pdv_controller.dart';

class PdvFooter extends StatelessWidget {
  const PdvFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PdvController>();

    return Obx(() {
      final rawOriginal = controller.sistemaRaw.value;

      if (rawOriginal.isEmpty) {
        return const SizedBox.shrink();
      }

      // Remove somente o "S|" inicial para exibição
      final raw = rawOriginal.startsWith('S|')
          ? rawOriginal.substring(2)
          : rawOriginal;

      final online = controller.servidorOnline.value;

      return Container(
        height: 30,

        // ONLINE = VERDE
        // OFFLINE = VERMELHO
        color: online ? const Color(0xFF168A3A) : const Color(0xFFC62828),

        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              raw,
              maxLines: 1,
              softWrap: false,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    });
  }
}
