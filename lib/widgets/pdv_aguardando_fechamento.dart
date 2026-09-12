import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pdv_convencional/config/pdv_paths.dart';

class PdvAguardandoFechamento extends StatelessWidget {
  const PdvAguardandoFechamento({super.key});

  @override
  Widget build(BuildContext context) {
    final logoFile = File(
      '${PdvPaths.pictures}${Platform.pathSeparator}logo.png',
    );
    final clock = File('${PdvPaths.lottie}${Platform.pathSeparator}clock.json');

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Aguardando fechamento do caixa',
                  style: GoogleFonts.montserrat(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 30),
                if (clock.existsSync())
                  SizedBox(
                    height: 280,
                    child: Lottie.file(
                      clock,
                      fit: BoxFit.contain,
                      frameRate: FrameRate(60),
                    ),
                  ),
                const SizedBox(height: 30),
                Text(
                  'Terminal temporariamente indisponível',
                  style: GoogleFonts.inter(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    fontSize: 24,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
