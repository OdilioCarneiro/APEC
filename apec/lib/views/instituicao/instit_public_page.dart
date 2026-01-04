import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:apec/services/api_service.dart';
import 'package:apec/pages/data/model.dart';
import 'package:apec/pages/components/card.dart';

class InstituicaoPublicaPage extends StatefulWidget {
  final Instituicao instituicao;
  const InstituicaoPublicaPage({super.key, required this.instituicao});

  @override
  State<InstituicaoPublicaPage> createState() => _InstituicaoPublicaPageState();
}

class _InstituicaoPublicaPageState extends State<InstituicaoPublicaPage> {
  bool _loadingEventos = true;
  String? _erroEventos;
  List<dynamic> _eventos = [];

  static const _gradColors = <Color>[
    Color(0xFFFA4050),
    Color(0xFF59B0E3),
    Color(0xFFF5E15F),
  ];

  @override
  void initState() {
    super.initState();
    _carregarEventos();
  }

  Future<void> _carregarEventos() async {
    setState(() {
      _loadingEventos = true;
      _erroEventos = null;
    });

    try {
      final list = await ApiService.listarEventos();
      final id = (widget.instituicao.id ?? '').toString();

      final filtrados = list.where((raw) {
        if (raw is! Map<String, dynamic>) return false;
        final instRaw = raw['instituicaoId'];
        if (instRaw is Map<String, dynamic>) {
          return (instRaw['_id'] ?? instRaw['id'] ?? '').toString() == id;
        }
        return (instRaw ?? '').toString() == id;
      }).toList();

      if (!mounted) return;
      setState(() {
        _eventos = filtrados;
        _loadingEventos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erroEventos = e.toString();
        _loadingEventos = false;
      });
    }
  }

  Future<void> _abrirEvento(Evento evento) async {
    await context.push(
      '/evento',
      extra: {'evento': evento, 'isDono': false},
    );
  }

  @override
  Widget build(BuildContext context) {
    final inst = widget.instituicao;

    final nome = (inst.nome ?? '').trim().isEmpty ? 'Instituição' : (inst.nome ?? '').trim();
    final bioRaw = (inst.descricao ?? '').trim();
    final bio = bioRaw.isEmpty ? 'Sem biografia.' : bioRaw;

    final fotoUrl = inst.imagem.trim().isEmpty ? null : inst.imagem.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: LayoutBuilder( // RESPONSIVO
        builder: (context, constraints) {
          final w = constraints.maxWidth;

          // largura máxima do conteúdo (pra não esticar no web/tablet)
          final contentMaxWidth = w >= 1100 ? 980.0 : (w >= 800 ? 760.0 : double.infinity); // RESPONSIVO [web:491]
          final horizontalPadding = w >= 800 ? 24.0 : 16.0; // RESPONSIVO

          // largura do card horizontal (antes era 305 fixo)
          final cardWidth = (w * 0.82).clamp(260.0, 360.0); // RESPONSIVO

          // altura do header um pouco maior em telas grandes
          final expandedHeight = (w >= 800) ? 280.0 : 240.0; // RESPONSIVO

          // avatar escala levemente em telas grandes
          final avatarSize = (w >= 800) ? 118.0 : 106.0; // RESPONSIVO

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: expandedHeight,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                ),
                title: Text(
                  nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFE5E5),
                              Color(0xFFE5F7FF),
                              Color.fromARGB(255, 251, 255, 229),
                            ],
                          ),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.04),
                              Colors.black.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: _AvatarInstituicaoGradient(
                            fotoUrl: fotoUrl,
                            size: avatarSize, // RESPONSIVO
                            borderThickness: 3.5,
                            gradientColors: _gradColors,
                            fallbackText: _iniciais(nome),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Center( 
                  child: ConstrainedBox( 
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 20), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                         Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 560), 
                              child: Card(
                                elevation: 0,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        nome,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF263238),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        bio,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          height: 1.45,
                                          color: Color(0xFF607D8B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),


                          const SizedBox(height: 14),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Eventos',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF263238),
                                ),
                              ),
                              TextButton(
                                onPressed: _carregarEventos,
                                child: const Text('Atualizar'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (_loadingEventos)
                            const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()))
                          else if (_erroEventos != null)
                            SizedBox(
                              height: 160,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.red, size: 34),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Erro ao carregar eventos.',
                                      style: TextStyle(
                                        color: Color(0xFF263238),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _erroEventos!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Color(0xFF607D8B), fontSize: 12),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 10),
                                    FilledButton.tonal(
                                      onPressed: _carregarEventos,
                                      child: const Text('Tentar novamente'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else if (_eventos.isEmpty)
                            const SizedBox(
                              height: 120,
                              child: Center(
                                child: Text(
                                  'Nenhum evento cadastrado.',
                                  style: TextStyle(
                                    color: Color(0xFF607D8B),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              height: 160,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _eventos.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 14),
                                itemBuilder: (context, index) {
                                  final raw = _eventos[index] as Map<String, dynamic>;
                                  final evento = Evento.fromAPI(raw);

                                  return InkWell(
                                    onTap: () => _abrirEvento(evento),
                                    borderRadius: BorderRadius.circular(16),
                                    child: SizedBox(
                                      width: cardWidth, // RESPONSIVO (antes 305 fixo)
                                      child: EventCardComponent(
                                        evento: evento,
                                        isDono: false,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _iniciais(String nome) {
    final parts = nome.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'IF';
    final first = parts.first.characters.first.toUpperCase();
    final last = parts.length > 1 ? parts.last.characters.first.toUpperCase() : '';
    return (first + last).trim();
  }
}

class _AvatarInstituicaoGradient extends StatelessWidget {
  final String? fotoUrl;
  final double size;
  final double borderThickness;
  final List<Color> gradientColors;
  final String fallbackText;

  const _AvatarInstituicaoGradient({
    required this.fotoUrl,
    required this.size,
    required this.borderThickness,
    required this.gradientColors,
    required this.fallbackText,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
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
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        fallbackText,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      fallbackText,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
