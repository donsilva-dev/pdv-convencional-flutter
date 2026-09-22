import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdv_convencional/config/pdv_paths.dart';

class PdvSaidaOperador extends StatefulWidget {
  const PdvSaidaOperador({super.key});

  @override
  State<PdvSaidaOperador> createState() => _PdvSaidaOperadorState();
}

class _PdvSaidaOperadorState extends State<PdvSaidaOperador>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animatiom;

  void initState() {
    super.initState();

    // 2. Configura o controlador da animação (duração do pulso)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // 3. Define a escala do pulso (vai de 1.0 até 1.25 do tamanho original)
    _animatiom = Tween<double>(
      begin: 1.0,
      end: 1.25,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 4. Faz a animação ir e voltar continuamente (efeito pulsar)
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose(); // Importante descarregar da memória ao fechar a tela
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoFile = File(
      '${PdvPaths.pictures}${Platform.pathSeparator}logo.png',
    );
    final saidaOperador = File(
      '${PdvPaths.svg}${Platform.pathSeparator}saida_operador.svg',
    );
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
                    'Saida de operador',
                    style: GoogleFonts.montserrat(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 65,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 60),
                  ScaleTransition(
                    scale: _animatiom,
                    child: saidaOperador.existsSync()
                        ? SvgPicture.file(
                            saidaOperador,
                            width: 200,
                            height: 200,
                          )
                        : const Icon(
                            Icons.warning_amber_rounded,
                            size: 200,
                            color: Colors.orange,
                          ),
                  ),
                  SizedBox(height: 60),
                  Text(
                    'Aguarde...',
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
