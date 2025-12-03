import 'package:flutter/material.dart';
import 'package:apec/pages/data/model.dart'; // seu modelo

// Amostras (remova se vierem do seu backend)
final Instituicao instituicaoSample = Instituicao(
  imagem: 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?auto=format&fit=crop&w=800&q=60',
);

final Evento sampleEvento = Evento(
  nome: 'Corrida Solidária',
  categoria: Categoria.esportiva,
  descricao: 'Corrida de 5km para arrecadar alimentos.',
  data: '2025-12-01',
  local: 'Parque Central',
  horario: '7:30',
  imagem: 'https://images.unsplash.com/photo-1508609349937-5ec4ae374ebf?auto=format&fit=crop&w=800&q=60',
);

void main() => runApp(const CardApp());

class CardApp extends StatelessWidget {
  const CardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Card Sample')),
        body: const CardExample(),
      ),
    );
  }
}

class CardExample extends StatelessWidget {
  const CardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        clipBehavior: Clip.hardEdge, // evita “vazar” conteúdo fora do card
        child: SizedBox(
          width: 305,
          height: 140,
          child: Stack(
            children: [
              // Imagem de fundo (instituição) com cantos suaves
              ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Image.network(
                  instituicaoSample.imagem,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.broken_image)),
                ),
              ),

              // Camada por cima (imagem do evento)
              ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Image.network(
                  sampleEvento.imagem,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.broken_image)),
                ),
              ),

              // Sombra inferior para contraste do texto
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.8),
                      spreadRadius: 6,
                      blurRadius: 18,
                      offset: const Offset(0, 80),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sampleEvento.nome,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 0),
                      Text(
                        '${sampleEvento.data}  • ${sampleEvento.horario}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Roboto',
                          fontSize: 12,
                        ),
                      ),
                      Text(
                       sampleEvento.local,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Roboto',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Avatar circular com borda gradiente e fundo branco (top-right com margem)
              Positioned(
                top: 6,     // ajuste de afastamento do topo
                right: 14,  // ajuste para “sair” da extremidade
                child: _GradientCircleAvatar(
                  imageUrl: instituicaoSample.imagem, // ou sampleEvento.imagem
                  size: 40,          // diâmetro total (borda + conteúdo)
                  borderThickness: 2, // espessura da borda
                  gradientColors: const [
                    Color(0xFFFA4050), // FA4050
                    Color(0xFF59B0E3), // 59B0E3
                    Color(0xFFF5E15F), // F5E15F
                  ],
                ),
              ),

              // Camada de toque
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(80),
                    highlightColor: const Color.fromARGB(255, 45, 155, 244),
                    onTap: () => debugPrint('Card tapped.'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientCircleAvatar extends StatelessWidget {
  final String imageUrl;
  final double size; 
  final double borderThickness;
  final List<Color> gradientColors;

  const _GradientCircleAvatar({
    required this.imageUrl,
    required this.size,
    required this.borderThickness,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Gradiente como "borda" externa
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(borderThickness),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white, 
          ),
          child: ClipOval(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.person_off)),
            ),
          ),
        ),
      ),
    );
  }
}
