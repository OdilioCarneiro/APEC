import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:apec/pages/data/data.dart'; // cardContentsport
import 'package:apec/pages/data/model.dart';
import 'package:apec/services/api_service.dart';
import 'package:apec/pages/components/card.dart';

import 'package:apec/views/filtros/subevento_filtro_sport.dart'; // SubEventosPorCategoriaEsportivaPage

class SportPage extends StatefulWidget {
  const SportPage({super.key});

  @override
  State<SportPage> createState() => _SportPageState();
}

class _SportPageState extends State<SportPage> {
  late Future<List<dynamic>> _eventosAPI;

  @override
  void initState() {
    super.initState();
    _eventosAPI = ApiService.listarEventos();
  }

  bool _isEventoEsportivo(Evento e) =>
      e.categoria == Categoria.esportiva || e.categoria == Categoria.ambos;

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

              const Divider(
                height: 10,
                thickness: 1,
                color: Color(0x1F000000),
              ),

              // ====== CARROSSEL DE MODALIDADES (ABRE PÁGINA) ======
              const SizedBox(height: 12),
              SizedBox(
                height: 152,
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
                            builder: (_) => SubEventosPorCategoriaEsportivaPage(
                              categoriaEsportivaKey: c.key, // ex: 'natacao', 'basquete'...
                              titulo: c.title,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),
              const Text(
                'Próximos eventos',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),

              FutureBuilder<List<dynamic>>(
                future: _eventosAPI,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 190,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return SizedBox(
                      height: 190,
                      child: Row(
                        children: [
                          const Expanded(child: Text('Erro ao carregar eventos')),
                          TextButton(
                            onPressed: () => setState(() {
                              _eventosAPI = ApiService.listarEventos();
                            }),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    );
                  }

                  final eventos = (snapshot.data ?? [])
                      .whereType<Map<String, dynamic>>()
                      .map(Evento.fromAPI)
                      .where(_isEventoEsportivo)
                      .toList();

                  if (eventos.isEmpty) {
                    return const SizedBox(
                      height: 190,
                      child: Center(child: Text('Nenhum evento esportivo encontrado')),
                    );
                  }

                  return SizedBox(
                    height: 190,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: eventos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final evento = eventos[index];
                        return SizedBox(
                          width: 320,
                          child: EventCardComponent(evento: evento),
                        );
                      },
                    ),
                  );
                },
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
    final screenWidth = MediaQuery.of(context).size.width;
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
                    child: AspectRatio(
                      aspectRatio: 1,
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
