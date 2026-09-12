import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pdv_convencional/config/pdv_paths.dart';

class PdvAbrirGaveta extends StatelessWidget {
  const PdvAbrirGaveta({super.key});

  @override
  Widget build(BuildContext context) {
    final logoFile = File(
      '${PdvPaths.pictures}${Platform.pathSeparator}logo.png',
    );

    final abrirGaveta = File(
      '${PdvPaths.lottie}${Platform.pathSeparator}cash_jump.json',
    );

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // ====================================================
          // LOGO
          // ====================================================
          if (logoFile.existsSync())
            Positioned(
              top: 20,
              left: 20,
              child: SizedBox(height: 80, child: Image.file(logoFile)),
            ),

          // ====================================================
          // CONTEÚDO
          // ====================================================
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Liberando Gaveta do Caixa',
                    style: GoogleFonts.montserrat(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 65,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 30),

                  if (abrirGaveta.existsSync())
                    SizedBox(
                      height: 280,
                      child: Lottie.file(
                        abrirGaveta,
                        fit: BoxFit.contain,
                        frameRate: FrameRate(60),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
