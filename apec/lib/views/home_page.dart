import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:apec/pages/data/model.dart';
import 'package:apec/services/api_service.dart';
import 'package:apec/pages/components/card.dart';
import 'package:apec/utils/debouncer.dart'; // <--- Certifique-se que este arquivo existe

const titleColor = Color(0xFF263238);

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Dados iniciais (Destaques)
  late Future<List<dynamic>> _eventosIniciais;
  late Future<List<dynamic>> _instituicoesIniciais;

  // Controle da Busca
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 500);
  bool _isSearching = false; // "Estou buscando?"
  bool _isLoading = false;   // "Estou carregando?"

  // Resultados
  List _resEventos = [];
  List _resInstituicoes = [];
  List _resSubeventos = [];

  @override
  void initState() {
    super.initState();
    _eventosIniciais = ApiService.listarEventos();
    _instituicoesIniciais = ApiService.listarInstituicoes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _isLoading = false;
        _resEventos = [];
        _resInstituicoes = [];
        _resSubeventos = [];
      }); 
      return;
    }

    setState(() => _isLoading = true);

    _debouncer.run(() async {
      final results = await ApiService.pesquisarTudo(query);
      if (!mounted) return;

      setState(() {
        _isSearching = true;
        _isLoading = false;
        _resEventos = results['eventos']!;
        _resInstituicoes = results['instituicoes']!;
        _resSubeventos = results['subeventos']!;
      });
    });
  }

  Future<void> _abrirInstituicao(Instituicao inst) async {
    await context.push('/instituicao', extra: inst);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = (size.width * 0.05).clamp(16.0, 32.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === BARRA UNIFICADA (CORRIGIDA) ===
              // Usamos Stack para evitar o erro de 'suffixIcon'
              Stack(
                alignment: Alignment.centerRight,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0x33263238), width: 1),
                    ),
                    child: CupertinoSearchTextField(
                      controller: _searchController,
                      placeholder: 'Buscar eventos, instituições...',
                      backgroundColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      onChanged: _onSearchChanged,
                      // Não definimos suffixIcon aqui para evitar erro de tipo
                    ),
                  ),
                  
                  // O indicador de carregamento fica flutuando aqui
                  if (_isLoading)
                    const Positioned(
                      right: 12,
                      child: CupertinoActivityIndicator(),
                    ),
                ],
              ),
              
              const SizedBox(height: 20),

              // === CONTEÚDO (Alterna entre Busca e Home) ===
              _isSearching ? _buildResultados() : _buildHomeNormal(),
            ],
          ),
        ),
      ),
    );
  }

  // TELA DE RESULTADOS DA BUSCA
  Widget _buildResultados() {
    final nadaEncontrado = !_isLoading && 
        _resEventos.isEmpty && 
        _resInstituicoes.isEmpty && 
        _resSubeventos.isEmpty;

    if (nadaEncontrado) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text("Nada encontrado.", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Instituições Encontradas
        if (_resInstituicoes.isNotEmpty) ...[
          _titulo('Instituições'),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _resInstituicoes.length,
              separatorBuilder: (_,__) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final inst = Instituicao.fromAPI(_resInstituicoes[i]);
                return _InstituicaoChip(
                  instituicao: inst, 
                  onTap: () => _abrirInstituicao(inst)
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
        
        // 2. Eventos Encontrados
        if (_resEventos.isNotEmpty) ...[
          _titulo('Eventos'),
          LayoutBuilder(builder: (context, constraints) {
             final maxWidth = constraints.maxWidth;
             const minCardWidth = 260.0;
             const maxCardWidth = 340.0;
             final columns = (maxWidth / minCardWidth).floor().clamp(1, 4);
             final effectiveCardWidth = (maxWidth - (columns - 1) * 18) / columns;
             final cardWidth = effectiveCardWidth.clamp(minCardWidth, maxCardWidth);

             return Wrap(
               spacing: 18, runSpacing: 18,
               children: _resEventos.map((e) {
                 final evento = Evento.fromAPI(e);
                 return SizedBox(width: cardWidth, child: EventCardComponent(evento: evento));
               }).toList(),
             );
          }),
          const SizedBox(height: 20),
        ],

        // 3. Subeventos Encontrados
        if (_resSubeventos.isNotEmpty) ...[
          _titulo('Atividades & Palestras'),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _resSubeventos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _SubeventoCard(data: _resSubeventos[i]),
          ),
        ],
      ],
    );
  }

  // TELA HOME NORMAL (Destaques iniciais)
  Widget _buildHomeNormal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titulo('Instituições'),
        SizedBox(
          height: 86,
          child: FutureBuilder<List>(
            future: _instituicoesIniciais,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CupertinoActivityIndicator());
              }
              if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
                return const Text('Nenhuma instituição encontrada');
              }
              
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: snap.data!.length,
                separatorBuilder: (_,__) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final raw = snap.data![i];
                  if (raw is! Map<String, dynamic>) return const SizedBox.shrink();
                  final inst = Instituicao.fromAPI(raw);
                  
                  return _InstituicaoChip(
                    instituicao: inst,
                    onTap: () => _abrirInstituicao(inst)
                  );
                },
              );
            },
          ),
        ),
        
        const SizedBox(height: 20),
        
        const Text('Eventos culturais', 
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: titleColor, height: 1.1)
        ),
        const SizedBox(height: 10),
        
        FutureBuilder<List>(
          future: _eventosIniciais,
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CupertinoActivityIndicator()),
              );
            }
            if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
              return const Center(child: Text('Nenhum evento encontrado'));
            }

            return LayoutBuilder(builder: (context, constraints) {
               final maxWidth = constraints.maxWidth;
               const minCardWidth = 260.0;
               const maxCardWidth = 340.0;
               final columns = (maxWidth / minCardWidth).floor().clamp(1, 4);
               final effectiveCardWidth = (maxWidth - (columns - 1) * 18) / columns;
               final cardWidth = effectiveCardWidth.clamp(minCardWidth, maxCardWidth);

               return Wrap(
                 spacing: 18, runSpacing: 18,
                 children: snap.data!.map((e) {
                   final evento = Evento.fromAPI(e as Map<String, dynamic>);
                   return SizedBox(width: cardWidth, child: EventCardComponent(evento: evento));
                 }).toList(),
               );
            });
          },
        ),
      ],
    );
  }

  Widget _titulo(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 12, top: 5),
    child: Text(t, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: titleColor))
  );
}

// === WIDGETS AUXILIARES ===

class _SubeventoCard extends StatelessWidget {
  final Map data;
  const _SubeventoCard({required this.data});
  @override
  Widget build(BuildContext context) {
    final pai = data['eventoId'] is Map ? data['eventoId']['nome'] : 'Evento Principal';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.class_, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['titulo'] ?? 'Sem título', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Em: $pai', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

class _InstituicaoChip extends StatelessWidget {
  final Instituicao instituicao;
  final VoidCallback onTap;

  const _InstituicaoChip({required this.instituicao, required this.onTap});

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
              gradientColors: const [Color(0xFFFA4050), Color(0xFF59B0E3), Color(0xFFF5E15F)],
            ),
            const SizedBox(height: 6),
            Text(
              nome.isEmpty ? 'Instit.' : nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF263238)),
            ),
          ],
        ),
      ),
    );
  }

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
        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: Padding(
        padding: EdgeInsets.all(borderThickness),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
          child: ClipOval(
            child: hasUrl
                ? Image.network(fotoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Text('IF')))
                : const Center(child: Text('IF', style: TextStyle(fontWeight: FontWeight.w800))),
          ),
        ),
      ),
    );
  }
}
