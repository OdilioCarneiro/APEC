import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}

class SegundaTela extends StatelessWidget {
  const SegundaTela({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final shortestSide = size.shortestSide;

    final bool isSmallPhone = shortestSide < 360;

    // Altura da ilustração proporcional à tela
    final double illustrationHeight =
        (screenHeight * 0.45).clamp(240.0, 420.0);

    // Largura do botão proporcional com limites
    final double buttonWidth =
        (screenWidth * 0.6).clamp(220.0, 320.0);
    final double buttonHeight = isSmallPhone ? 46.0 : 52.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08, // 8% de cada lado
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ilustração SVG responsiva
                SizedBox(
                  height: illustrationHeight,
                  child: SvgPicture.asset(
                    'assets/starter_page.svg',
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: screenHeight * 0.06),

                // Botão com borda em gradiente, centralizado e responsivo
                DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 122, 122),
                        Color.fromARGB(255, 214, 233, 106),
                        Color.fromARGB(255, 123, 204, 250),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(60)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(60)),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(40)),
                        ),
                        child: SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: OutlinedButton(
                            onPressed: () => context.go('/tabview'),
                            style: OutlinedButton.styleFrom(
                              shape: const StadiumBorder(),
                              side: const BorderSide(
                                width: 0,
                                color: Colors.transparent,
                              ),
                            ),
                            child: const GradientText(
                              'Entrar',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 255, 122, 122),
                                  Color.fromARGB(255, 214, 233, 106),
                                  Color.fromARGB(255, 123, 204, 250),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
