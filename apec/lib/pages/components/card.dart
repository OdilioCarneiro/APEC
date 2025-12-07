import 'package:flutter/material.dart';
import 'package:apec/pages/data/model.dart';
import 'package:go_router/go_router.dart';

/// Widget reutilizável que exibe um card de evento
class EventCardComponent extends StatelessWidget {
  final Evento evento;
  final Instituicao? instituicao; // Opcional se quiser adicionar depois

  const EventCardComponent({
    required this.evento,
    this.instituicao,
    super.key,
  });

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
              // Imagem de fundo (instituição) se disponível
              if (instituicao != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: Image.network(
                    instituicao!.imagem,
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
                  evento.imagem,
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
                      color: Colors.black,
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
                        evento.nome,
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
                        '${evento.data}  • ${evento.horario}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Roboto',
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        evento.local,
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

           
              if (instituicao != null)
                Positioned(
                  top: 6,
                  right: 14,
                  child: _GradientCircleAvatar(
                    imageUrl: instituicao!.imagem,
                    size: 40,
                    borderThickness: 2,
                    gradientColors: const [
                      Color(0xFFFA4050),
                      Color(0xFF59B0E3),
                      Color(0xFFF5E15F),
                    ],
                  ),
                ),

      
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(80),
                    highlightColor: const Color.fromARGB(255, 45, 155, 244),
                    onTap: (){
                      context.push('/evento', extra: evento);
                    },
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
