import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdv_convencional/config/pdv_paths.dart';

class PdvSandria extends StatefulWidget {
  const PdvSandria({super.key});

  @override
  State<PdvSandria> createState() => _PdvSandriaState();
}

class _PdvSandriaState extends State<PdvSandria>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // 2. Configura o controlador da animação (duração do pulso)
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 1000,
      ), // Tempo de um pulso (1 segundo)
      vsync: this,
    );

    // 3. Define a escala do pulso (vai de 1.0 até 1.25 do tamanho original)
    _animation = Tween<double>(
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
    final retiradaSvg = File(
      '${PdvPaths.svg}${Platform.pathSeparator}retirada.svg',
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
              padding: EdgeInsets.only(top: 10),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Retirada, aguarde',
                    style: GoogleFonts.montserrat(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 65,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 60),
                  ScaleTransition(
                    scale: _animation,
                    child: retiradaSvg.existsSync()
                        ? SvgPicture.file(
                            retiradaSvg,
                            width: 200,
                            height: 200,
                            colorFilter: ColorFilter.mode(
                              Colors.red,
                              BlendMode.srcIn,
                            ),
                          )
                        : const Icon(
                            Icons.warning_amber_rounded,
                            size: 200,
                            color: Colors.orange,
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
