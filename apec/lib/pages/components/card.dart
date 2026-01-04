import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:apec/pages/data/model.dart';

class EventCardComponent extends StatelessWidget {
  final Evento evento;

  /// Na Home: false (padrão)
  /// No admin/perfil instituição: true
  final bool isDono;

  const EventCardComponent({
    super.key,
    required this.evento,
    this.isDono = false,
  });

  @override
  Widget build(BuildContext context) {
    // Se seu Evento.fromAPI preencher evento.instituicao, dá pra mostrar bolinha.
    final inst = evento.instituicao;

    return Center(
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: 305,
          height: 140,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  evento.imagem,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade300,
                    child: const Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              ),

              Container(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(120, 0, 0, 0),
                      spreadRadius: 6,
                      blurRadius: 18,
                      offset: Offset(0, 80),
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
                      Text(
                        '${evento.data} • ${evento.horario}',
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

              // bolinha (só aparece se tiver populate/URL)
              if (inst != null && inst.imagem.isNotEmpty)
                Positioned(
                  top: 6,
                  right: 14,
                  child: _GradientCircleAvatar(
                    imageUrl: inst.imagem,
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
                    onTap: () {
                      context.push(
                        '/evento',
                        extra: {'evento': evento, 'isDono': isDono},
                      );
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
              errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.person_off)),
            ),
          ),
        ),
      ),
    );
  }
}
