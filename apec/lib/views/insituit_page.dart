import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:apec/services/api_service.dart';

class PerfilInstituicaoPage extends StatefulWidget {
  const PerfilInstituicaoPage({super.key});

  @override
  State<PerfilInstituicaoPage> createState() => _PerfilInstituicaoPageState();
}

class _PerfilInstituicaoPageState extends State<PerfilInstituicaoPage> {
  late Future<Map<String, dynamic>> _perfilFuture;
  late Future<List<dynamic>> _eventosFuture;

  @override
  void initState() {
    super.initState();
    _perfilFuture = ApiService.minhaInstituicao();
    _eventosFuture = ApiService.meusEventos();
  }

  void _recarregarEventos() {
    setState(() {
      _eventosFuture = ApiService.meusEventos();
    });
  }

  Future<void> _abrirCadastroEvento() async {
    final bool? criou = await context.push<bool>('/cadastro_evento');
    if (criou == true) _recarregarEventos();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final horizontalPadding = (screenWidth * 0.05).clamp(16.0, 24.0);

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFF4),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFE5E5), Color(0xFFE5F7FF), Color(0xFFEDE5FF)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(horizontalPadding),
              child: FutureBuilder<Map<String, dynamic>>(
                future: _perfilFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro perfil: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text('Sem dados de perfil.'));
                  }

                  final inst = snapshot.data!;
                  final nome = (inst['nome'] ?? '').toString();
                  final campus = (inst['campus'] ?? '').toString();
                  final bio = (inst['bio'] ?? '').toString();
                  final fotoUrl = inst['fotoUrl']?.toString();

                  return _PerfilCard(
                    horizontalPadding: horizontalPadding,
                    nome: nome,
                    campus: campus,
                    bio: bio,
                    fotoUrl: fotoUrl,
                    eventosFuture: _eventosFuture,
                    onAddEvento: _abrirCadastroEvento,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PerfilCard extends StatelessWidget {
  final double horizontalPadding;
  final String nome;
  final String campus;
  final String bio;
  final String? fotoUrl;
  final Future<List<dynamic>> eventosFuture;
  final VoidCallback onAddEvento;

  const _PerfilCard({
    required this.horizontalPadding,
    required this.nome,
    required this.campus,
    required this.bio,
    required this.fotoUrl,
    required this.eventosFuture,
    required this.onAddEvento,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 2 * horizontalPadding).clamp(320.0, 500.0);

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.redAccent, width: 3),
              color: Colors.grey.shade200,
            ),
            child: ClipOval(
              child: (fotoUrl == null || fotoUrl!.isEmpty)
                  ? const Center(
                      child: Text('IF', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28)),
                    )
                  : Image.network(
                      fotoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text('IF', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28)),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            nome.isEmpty ? 'Instituição' : nome,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF263238)),
          ),
          const SizedBox(height: 4),
          Text(
            campus.isEmpty ? 'Campus/Região' : campus,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            bio.isEmpty ? 'Sem biografia.' : bio,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, height: 1.3, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 24),
          _SecaoEventos(eventosFuture: eventosFuture, onAddEvento: onAddEvento),
        ],
      ),
    );
  }
}

class _SecaoEventos extends StatelessWidget {
  final Future<List<dynamic>> eventosFuture;
  final VoidCallback onAddEvento;

  const _SecaoEventos({required this.eventosFuture, required this.onAddEvento});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text('Eventos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF263238))),
            SizedBox(width: 4),
            Icon(Icons.edit, size: 16, color: Color(0xFF263238)),
          ],
        ),
        const SizedBox(height: 8),

        SizedBox(
          height: 140,
          child: FutureBuilder<List<dynamic>>(
            future: eventosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erro eventos: ${snapshot.error}'));
              }

              final eventos = snapshot.data ?? [];

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 1 + eventos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  if (index == 0) return _AddCard(onTap: onAddEvento);

                  final e = eventos[index - 1] as Map<String, dynamic>;
                  return _EventoCard(evento: e);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AddCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AddCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 260,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0E0E0), Color(0xFFBDBDBD)],
          ),
        ),
        child: Center(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey, width: 3),
            ),
            child: const Icon(Icons.add, size: 28, color: Colors.black54),
          ),
        ),
      ),
    );
  }
}

class _EventoCard extends StatelessWidget {
  final Map<String, dynamic> evento;
  const _EventoCard({required this.evento});

  @override
  Widget build(BuildContext context) {
    final titulo = (evento['nome'] ?? 'Evento').toString();

    // Se veio populate, instituicaoId vira objeto {nome, fotoUrl}
    final inst = evento['instituicaoId'];
    String instNome = '';
    String instFoto = '';

    if (inst is Map<String, dynamic>) {
      instNome = (inst['nome'] ?? '').toString();
      instFoto = (inst['fotoUrl'] ?? '').toString();
    }

    return Container(
      width: 260,
      height: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: instFoto.isNotEmpty ? NetworkImage(instFoto) : null,
                child: instFoto.isEmpty
                    ? const Icon(Icons.school, size: 16, color: Colors.black54)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  instNome.isEmpty ? 'Instituição' : instNome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            titulo,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
