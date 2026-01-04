import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
// Ajuste os caminhos se necessário
import 'package:apec/pages/data/model.dart';
import 'package:apec/services/api_service.dart';
import 'package:apec/pages/components/card.dart';
import 'package:apec/utils/debouncer.dart';

const titleColor = Color(0xFF263238);

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _eventosIniciais;
  late Future<List<dynamic>> _instituicoesIniciais;

  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 500);
  
  bool _isSearching = false;
  bool _isLoading = false;

  List<dynamic> _resEventos = [];
  List<dynamic> _resInstituicoes = [];
  List<dynamic> _resSubeventos = [];

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
        // Garante que é List<dynamic>
        _resEventos = results['eventos'] ?? [];
        _resInstituicoes = results['instituicoes'] ?? [];
        _resSubeventos = results['subeventos'] ?? [];
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
              // === BARRA DE PESQUISA ===
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
                      // Removido prefixIcon/suffixIcon para evitar conflito
                    ),
                  ),
                  if (_isLoading)
                    const Positioned(
                      right: 12,
                      child: CupertinoActivityIndicator(),
                    ),
                ],
              ),
              
              const SizedBox(height: 20),

              // === CONTEÚDO ===
              _isSearching ? _buildResultados() : _buildHomeNormal(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultados() {
    final bool nadaEncontrado = !_isLoading && 
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
        if (_resInstituicoes.isNotEmpty) ...[
          _titulo('Instituições'),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _resInstituicoes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (ctx, i) {
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
        
        if (_resEventos.isNotEmpty) ...[
          _titulo('Eventos'),
          LayoutBuilder(builder: (context, constraints) {
             final maxWidth = constraints.maxWidth;
             // Ajuste para evitar divisão por zero
             final columns = (maxWidth / 260.0).floor().clamp(1, 4);
             final cardWidth = ((maxWidth - (columns - 1) * 18) / columns).clamp(260.0, 340.0);

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

  Widget _buildHomeNormal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titulo('Instituições'),
        SizedBox(
          height: 86,
          child: FutureBuilder<List<dynamic>>(
            future: _instituicoesIniciais,
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CupertinoActivityIndicator());
              }
              if (snap.hasError) return const Text('Erro ao carregar');
              final list = snap.data ?? [];
              if (list.isEmpty) return const Text('Nenhuma instituição');
              
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (_,__) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final raw = list[i];
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
        
        FutureBuilder<List<dynamic>>(
          future: _eventosIniciais,
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(child: CupertinoActivityIndicator()),
              );
            }
            if (snap.hasError) return const Text('Erro ao carregar');
            final list = snap.data ?? [];
            if (list.isEmpty) return const Center(child: Text('Nenhum evento'));

            return LayoutBuilder(builder: (context, constraints) {
               final maxWidth = constraints.maxWidth;
               final columns = (maxWidth / 260.0).floor().clamp(1, 4);
               final cardWidth = ((maxWidth - (columns - 1) * 18) / columns).clamp(260.0, 340.0);

               return Wrap(
                 spacing: 18, runSpacing: 18,
                 children: list.map((e) {
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

// WIDGETS AUXILIARES

class _SubeventoCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _SubeventoCard({required this.data}); // Removido Key para simplificar
  
  @override
  Widget build(BuildContext context) {
    // Tratamento seguro para 'eventoId'
    String nomePai = 'Evento';
    if (data['eventoId'] != null && data['eventoId'] is Map) {
      nomePai = data['eventoId']['nome'] ?? 'Evento';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.class_, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['titulo'] ?? 'Sem título', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Em: $nomePai', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
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
    final fotoUrl = instituicao.imagem.trim().isEmpty ? null : _safeUrl(instituicao.imagem);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _AvatarGradient(fotoUrl: fotoUrl, size: 54),
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

  String? _safeUrl(String? raw) {
    final s = (raw ?? '').trim();
    if (s.isEmpty) return null;
    if (s.startsWith('http')) return s;
    return 'https://$s';
  }
}

class _AvatarGradient extends StatelessWidget {
  final String? fotoUrl;
  final double size;
  
  // Construtor simplificado sem opcionais problemáticos
  const _AvatarGradient({
    required this.fotoUrl,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFFA4050), Color(0xFF59B0E3), Color(0xFFF5E15F)],
          begin: Alignment.topCenter, 
          end: Alignment.bottomCenter
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
          child: ClipOval(
            child: fotoUrl != null
                ? Image.network(fotoUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Text('IF')))
                : const Center(child: Text('IF', style: TextStyle(fontWeight: FontWeight.w800))),
          ),
        ),
      ),
    );
  }
}
