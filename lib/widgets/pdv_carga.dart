import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:pdv_convencional/config/pdv_paths.dart';

class PdvCarga extends StatelessWidget {
  const PdvCarga({super.key});

  @override
  Widget build(BuildContext context) {
    final logoFile = File(
      '${PdvPaths.pictures}${Platform.pathSeparator}logo.png',
    );
    final carga = File('${PdvPaths.lottie}${Platform.pathSeparator}manut.json');
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
              padding: EdgeInsets.only(top: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Recebendo carga, Aguardem.',
                    style: GoogleFonts.montserrat(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 65,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 30),
                  if (carga.existsSync())
                    SizedBox(
                      height: 280,

                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.red,
                          BlendMode.srcATop,
                        ),
                        child: Lottie.file(
                          carga,
                          fit: BoxFit.contain,
                          frameRate: FrameRate(30),
                        ),
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
