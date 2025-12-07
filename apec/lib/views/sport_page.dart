import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:apec/pages/data/data.dart'; // contém List<CardContent> cardContent com os assets/cores informados

class SportPage extends StatelessWidget {
  const SportPage({super.key});

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF263238);
    final radius = BorderRadius.circular(20);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de busca (estilo iOS)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x33263238), width: 1),
                ),
                child: const CupertinoSearchTextField(
                  placeholder: 'Search',
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 16),

              // Título
              const Text(
                'Eventos esportivos',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),

              // Divisor
              const Divider(height: 10, thickness: 1, color: Color(0x1F000000)),

              // Carrossel de cards
              const SizedBox(height: 12),
              SizedBox(
                height: 168, 
                width: double.infinity,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: cardContentsport.length,
                  padding: const EdgeInsets.only(right: 8),
                  itemBuilder: (context, index) {
                    final c = cardContentsport[index];
                    return _SportTile(
                      title: c.title,
                      imageAsset: c.image,
                      background: c.backgroundColor,
                      radius: radius,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SportDetalhePage(content: c),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SportTile extends StatelessWidget {
  final String title;
  final String imageAsset;
  final Color background;
  final BorderRadius radius;
  final VoidCallback onTap;

  const _SportTile({
    required this.title,
    required this.imageAsset,
    required this.background,
    required this.radius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: SizedBox(
            width: 95,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                DecoratedBox(
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: radius,
                    border: Border.all(color: const Color(0x14000000), width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(26, 0, 0, 0),
                        blurRadius: 4,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: radius,
                    child: SizedBox(
                      width: 90,
                      height: 90,
                      child: SvgPicture.asset(
                        imageAsset,
                        fit: BoxFit.cover,
                        // Placeholder para diagnóstico rápido
                        placeholderBuilder: (_) => const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF263238),
                    fontSize: 12.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Exemplo simples de página de destino
class SportDetalhePage extends StatelessWidget {
  final CardContentsport content;
  const SportDetalhePage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(content.title)),
      body: Center(
        child: SvgPicture.asset(
          content.image,
          width: 260,
          height: 260,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
