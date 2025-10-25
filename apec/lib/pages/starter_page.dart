import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
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
    return Scaffold(
      backgroundColor: Colors.white,
       body: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Expanded(
      child: Transform.translate(
        offset: const Offset(20, -24), 
        child: SvgPicture.asset(
          'assets/starter_page.svg',
          fit: BoxFit.contain,
        ),
      ),
    ),
        Transform.translate(
      offset: const Offset(20, -200),
      child: DecoratedBox(
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
              child: OutlinedButton(
                onPressed: () => context.go('/HomePage'),
                style: OutlinedButton.styleFrom(
                  fixedSize: const Size(240, 48),
                  shape: const StadiumBorder(),
                  side: const BorderSide(width: 0, color: Colors.transparent),
                ),
                child: const GradientText(
                  'Entrar',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  gradient: LinearGradient(colors: [
                    Color.fromARGB(255, 255, 122, 122),
                    Color.fromARGB(255, 214, 233, 106),
                    Color.fromARGB(255, 123, 204, 250),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    )
  ],
)

          );
      }
  }
