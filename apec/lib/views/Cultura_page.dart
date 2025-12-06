import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:apec/pages/data/data.dart'; // contém List<CardContent> cardContent

class CulturaPage extends StatelessWidget {
  const CulturaPage({super.key});

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
              // Barra de busca
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0x33263238),
                    width: 1,
                  ),
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
                'Eventos culturais',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),

              // Divisor
              const Divider(
                height: 10,
                thickness: 1,
                color: Color(0x1F000000),
              ),

              // Carrossel de cards
              const SizedBox(height: 12),
              SizedBox(
                height: 168,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: cardContent.length,
                  padding: const EdgeInsets.only(right: 8),
                  itemBuilder: (context, index) {
                    final c = cardContent[index];
                    return _CulturaTile(
                      title: c.title,
                      imageAsset: c.image,
                      background: c.backgroundColor,
                      radius: radius,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CulturaDetalhePage(content: c),
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

class _CulturaTile extends StatelessWidget {
  final String title;
  final String imageAsset;
  final Color background;
  final BorderRadius radius;
  final VoidCallback onTap;

  const _CulturaTile({
    required this.title,
    required this.imageAsset,
    required this.background,
    required this.radius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Largura responsiva: ~4 tiles por tela em celular, com limites
    final tileWidth = (screenWidth * 0.24).clamp(80.0, 130.0);

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: SizedBox(
            width: tileWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: radius,
                    border: Border.all(
                      color: const Color(0x14000000),
                      width: 2,
                    ),
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
                    child: AspectRatio(
                      aspectRatio: 1, // quadrado, ajusta à largura do tile
                      child: SvgPicture.asset(
                        imageAsset,
                        fit: BoxFit.cover,
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
                const SizedBox(height: 4),
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

// Página de detalhes
class CulturaDetalhePage extends StatelessWidget {
  final CardContent content;
  const CulturaDetalhePage({super.key, required this.content});

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
