import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import 'package:apec/pages/data/model.dart';
import 'package:apec/services/api_service.dart';
import 'package:apec/pages/components/card.dart';

const titleColor = Color(0xFF263238);

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _eventosAPI;
  late Future<List<dynamic>> _instituicoesAPI;

  @override
  void initState() {
    super.initState();
    _eventosAPI = ApiService.listarEventos();
    _instituicoesAPI = ApiService.listarInstituicoes();
  }

  Future<void> _abrirInstituicao(Instituicao inst) async {
    await context.push('/instituicao', extra: inst);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    final horizontalPadding = screenWidth * 0.05;
    final clampedPadding = horizontalPadding.clamp(16.0, 32.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: clampedPadding, vertical: 20),
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

              const SizedBox(height: 14),

              // ====== INSTITUIÇÕES (NOVA ROW) ======
              const Text(
                'Instituições',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 86,
                child: FutureBuilder<List<dynamic>>(
                  future: _instituicoesAPI,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Row(
                        children: [
                          const Expanded(child: Text('Erro ao carregar instituições')),
                          TextButton(
                            onPressed: () => setState(() {
                              _instituicoesAPI = ApiService.listarInstituicoes();
                            }),
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      );
                    }

                    final list = snapshot.data ?? [];
                    if (list.isEmpty) {
                      return const Center(child: Text('Nenhuma instituição cadastrada'));
                    }

                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final raw = list[index];
                        if (raw is! Map<String, dynamic>) return const SizedBox.shrink();

                        final inst = Instituicao.fromAPI(raw);
                        return _InstituicaoChip(
                          instituicao: inst,
                          onTap: () => _abrirInstituicao(inst),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

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

              FutureBuilder<List<dynamic>>(
                future: _eventosAPI,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Erro ao carregar eventos:\n${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => setState(() {
                                _eventosAPI = ApiService.listarEventos();
                              }),
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final eventos = snapshot.data ?? [];
                  if (eventos.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: Text('Nenhum evento encontrado')),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = constraints.maxWidth;

                        const minCardWidth = 260.0;
                        const maxCardWidth = 340.0;

                        final columns = (maxWidth / minCardWidth).floor().clamp(1, 4);
                        final effectiveCardWidth = (maxWidth - (columns - 1) * 18) / columns;
                        final cardWidth = effectiveCardWidth.clamp(minCardWidth, maxCardWidth);

                        return Wrap(
                          spacing: 18,
                          runSpacing: 18,
                          children: eventos.map((e) {
                            final evento = Evento.fromAPI(e as Map<String, dynamic>);
                            return SizedBox(
                              width: cardWidth,
                              child: EventCardComponent(evento: evento),
                            );
                          }).toList(),
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

class _InstituicaoChip extends StatelessWidget {
  final Instituicao instituicao;
  final VoidCallback onTap;

  const _InstituicaoChip({
    required this.instituicao,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nome = (instituicao.nome ?? '').trim();
    final fotoUrl = instituicao.imagem.trim().isEmpty ? null : instituuicaoSafeUrl(instituicao.imagem);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _AvatarInstituicaoGradient(
              fotoUrl: fotoUrl,
              size: 54,
              borderThickness: 2.5,
              gradientColors: const [
                Color(0xFFFA4050),
                Color(0xFF59B0E3),
                Color(0xFFF5E15F),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              nome.isEmpty ? 'Instit.' : nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF263238),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Se o backend já manda URL completa, isso não altera.
  // Se vier sem http/https, adiciona https:// (igual seu padrão de links).
  String? instituuicaoSafeUrl(String? raw) {
    final s = (raw ?? '').trim();
    if (s.isEmpty) return null;
    if (s.startsWith('http://') || s.startsWith('https://')) return s;
    return 'https://$s';
  }
}

class _AvatarInstituicaoGradient extends StatelessWidget {
  final String? fotoUrl;
  final double size;
  final double borderThickness;
  final List<Color> gradientColors;

  const _AvatarInstituicaoGradient({
    required this.fotoUrl,
    required this.size,
    required this.borderThickness,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = fotoUrl != null && fotoUrl!.trim().isNotEmpty;

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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
          ),
          child: ClipOval(
            child: hasUrl
                ? Image.network(
                    fotoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Text('IF', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    ),
                  )
                : const Center(
                    child: Text('IF', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  ),
          ),
        ),
      ),
    );
  }
}
