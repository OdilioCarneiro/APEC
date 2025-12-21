import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:apec/services/api_service.dart';
import 'package:apec/pages/data/model.dart';
import 'package:apec/pages/components/card.dart';

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
    setState(() => _eventosFuture = ApiService.meusEventos());
  }

  Future<void> _abrirCadastroEvento() async {
    await context.push('/cadastro_evento');
    _recarregarEventos();
  }

  // <<< MAIS FÁCIL: sempre recarrega quando voltar do /evento
  Future<void> _abrirEventoInstit(Evento evento) async {
    await context.push(
      '/evento',
      extra: {'evento': evento, 'isDono': true},
    );

    if (!mounted) return;
    _recarregarEventos();
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
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
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
                  final bio = (inst['bio'] ?? inst['descricao'] ?? '').toString();
                  final fotoUrl = (inst['fotoUrl'] ?? inst['imagem'])?.toString();

                  return _PerfilCard(
                    horizontalPadding: horizontalPadding,
                    nome: nome,
                    campus: campus,
                    bio: bio,
                    fotoUrl: fotoUrl,
                    eventosFuture: _eventosFuture,
                    onAddEvento: _abrirCadastroEvento,
                    onOpenEvento: _abrirEventoInstit, // <<< passa pro filho
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
  final void Function(Evento evento) onOpenEvento;

  const _PerfilCard({
    required this.horizontalPadding,
    required this.nome,
    required this.campus,
    required this.bio,
    required this.fotoUrl,
    required this.eventosFuture,
    required this.onAddEvento,
    required this.onOpenEvento,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    final cardWidth =
        (screenWidth - 2 * horizontalPadding).clamp(320.0, 500.0);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: screenHeight * 0.80,
      ),
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            _AvatarInstituicaoGradient(
              fotoUrl: fotoUrl,
              size: 96,
              borderThickness: 3,
              gradientColors: const [
                Color(0xFFFA4050),
                Color(0xFF59B0E3),
                Color(0xFFF5E15F),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              nome.isEmpty ? 'Instituição' : nome,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF263238),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              campus.isEmpty ? 'Campus/Região' : campus,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              bio.isEmpty ? 'Sem biografia.' : bio,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.3,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 24),
            _SecaoEventos(
              eventosFuture: eventosFuture,
              onAddEvento: onAddEvento,
              onOpenEvento: onOpenEvento, // <<< repassa pro neto
            ),
          ],
        ),
      ),
    );
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
                      child: Text(
                        'IF',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28),
                      ),
                    ),
                  )
                : const Center(
                    child: Text(
                      'IF',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SecaoEventos extends StatelessWidget {
  final Future<List<dynamic>> eventosFuture;
  final VoidCallback onAddEvento;
  final void Function(Evento evento) onOpenEvento;

  const _SecaoEventos({
    required this.eventosFuture,
    required this.onAddEvento,
    required this.onOpenEvento,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Eventos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF263238),
          ),
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

                  final raw = eventos[index - 1];
                  if (raw is! Map<String, dynamic>) {
                    return const SizedBox(
                      width: 260,
                      child: Center(child: Text('Evento inválido')),
                    );
                  }

                  final evento = Evento.fromAPI(raw);

                  return InkWell(
                    onTap: () => onOpenEvento(evento),
                    child: SizedBox(
                      width: 305,
                      child: EventCardComponent(
                        evento: evento,
                        isDono: true,
                      ),
                    ),
                  );
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
