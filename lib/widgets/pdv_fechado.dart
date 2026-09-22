import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdv_convencional/config/pdv_paths.dart';

class PdvFechado extends StatefulWidget {
  const PdvFechado({super.key});

  @override
  State<PdvFechado> createState() => _PdvFechadoState();
}

class _PdvFechadoState extends State<PdvFechado> {
  final logoFile = File(
    '${PdvPaths.pictures}${Platform.pathSeparator}logo.png',
  );
  final pdvFechado = File(
    '${PdvPaths.svg}${Platform.pathSeparator}fechado.svg',
  );
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          if (logoFile.existsSync())
            Positioned(
              top: 20,
              left: 20,
              child: SizedBox(height: 80, child: Image.file(logoFile)),
            ),
          Center(
            child: Padding(
              padding: EdgeInsetsGeometry.only(top: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Terminal fechado',
                    style: GoogleFonts.montserrat(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 65,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 60),
                  pdvFechado.existsSync()
                      ? SvgPicture.file(pdvFechado, width: 200, height: 200)
                      : const Icon(
                          Icons.warning_amber_rounded,
                          size: 200,
                          color: Colors.orange,
                        ),
                  SizedBox(height: 60),
                  Text(
                    ' Terminal inoperante',
                    style: GoogleFonts.inter(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 24,
                      color: Colors.grey.shade700,
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
