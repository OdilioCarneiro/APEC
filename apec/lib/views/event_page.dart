import 'dart:async';
import 'package:flutter/material.dart';

import 'package:apec/pages/data/model.dart';
import 'package:apec/services/api_service.dart';
import 'package:apec/pages/components/card_subevento.dart';

class EventPage extends StatefulWidget {
  final Evento evento;
  const EventPage({super.key, required this.evento});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  late Future<_EventPageData> _future;

  @override
  void initState() {
    super.initState();
    _future = _carregarTudo();
  }

  Future<void> _refresh() async {
    setState(() => _future = _carregarTudo());
    await _future;
  }

  Future<_EventPageData> _carregarTudo() async {
    final eventoId = widget.evento.id;

    // Se abrir sem id, renderiza com o que veio (sem backend).
    if (eventoId == null || eventoId.isEmpty) {
      return _EventPageData(
        evento: widget.evento,
        subeventos: const [],
      );
    }

    final results = await Future.wait([
      ApiService.obterEvento(eventoId),
      ApiService.listarSubEventos(eventoPaiId: eventoId),
    ]);

    final eventoJson = results[0] as Map<String, dynamic>;
    final subeventosRaw = results[1] as List<dynamic>;

    final eventoAtualizado = Evento.fromAPI(eventoJson);

    final subs = subeventosRaw
        .whereType<Map>()
        .map((e) => SubEvento.fromAPI(Map<String, dynamic>.from(e)))
        .toList();

    return _EventPageData(evento: eventoAtualizado, subeventos: subs);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_EventPageData>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snap.hasError) {
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Erro ao carregar o evento.',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snap.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => setState(() => _future = _carregarTudo()),
                        child: const Text('Tentar novamente'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Voltar'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final data = snap.data!;
        final evento = data.evento;
        final subs = data.subeventos;

        final size = MediaQuery.of(context).size;
        final screenHeight = size.height;

        final Gradient fundoEvento = (evento.categoria == Categoria.esportiva)
            ? LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [
                  const Color.fromARGB(255, 255, 255, 255),
                  Colors.yellow.shade300,
                ],
              )
            : const LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(255, 255, 110, 110),
                ],
              );

        // Mapa categoria -> lista
        final Map<String, List<SubEvento>> grupos = {};
        grupos['Subeventos'] = [];

        // Categorias cadastradas no Evento (mesmo vazias).
        // Aqui estava o bug: cat.titulo não existe se cat for String.
        final seen = <String>{'subeventos'};
        for (final cat in evento.categoriasSubeventos) {
          final titulo = cat.toString().trim();
          if (titulo.isEmpty) continue;

          final key = titulo.toLowerCase();
          if (seen.add(key)) {
            grupos.putIfAbsent(titulo, () => []);
          }
        }

        // Encaixa subeventos na categoria
        for (final s in subs) {
          final titulo = (s.categoria ?? '').trim().isEmpty ? 'Subeventos' : s.categoria!.trim();
          grupos.putIfAbsent(titulo, () => []);
          grupos[titulo]!.add(s);
        }

        // Ordenação: Subeventos primeiro, depois alfabético
        final categoriasOrdenadas = grupos.keys.toList()
          ..sort((a, b) {
            if (a.toLowerCase() == 'subeventos') return -1;
            if (b.toLowerCase() == 'subeventos') return 1;
            return a.toLowerCase().compareTo(b.toLowerCase());
          });

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(gradient: fundoEvento),
            child: SafeArea(
              child: Column(
                children: [
                  EventBanner(imagem: evento.imagem),
                  const SizedBox(height: 24),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 24),
                        children: [
                          EventTitle(title: evento.nome),
                          const SizedBox(height: 8),
                          EventDetailsRow(data: evento.data, local: evento.local),
                          const SizedBox(height: 12),
                          EventDescription(texto: evento.descricao),
                          const SizedBox(height: 16),

                          ...categoriasOrdenadas.map((cat) {
                            final lista = grupos[cat] ?? const <SubEvento>[];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _LinhaSubeventosReadOnly(
                                titulo: cat,
                                subeventos: lista,
                              ),
                            );
                          }),

                          SizedBox(height: screenHeight * 0.02),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EventPageData {
  final Evento evento;
  final List<SubEvento> subeventos;

  const _EventPageData({
    required this.evento,
    required this.subeventos,
  });
}

class _LinhaSubeventosReadOnly extends StatelessWidget {
  final String titulo;
  final List<SubEvento> subeventos;

  const _LinhaSubeventosReadOnly({
    required this.titulo,
    required this.subeventos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF263238),
          ),
        ),
        const SizedBox(height: 10),
        if (subeventos.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x33263238), width: 1),
            ),
            child: Text(
              'Sem subeventos nesta categoria.',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: subeventos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final sub = subeventos[index];
                return SubEventoCardComponent(subevento: sub);
              },
            ),
          ),
      ],
    );
  }
}

class EventBanner extends StatelessWidget {
  final String imagem;
  const EventBanner({super.key, required this.imagem});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bannerHeight = (screenWidth * 0.56).clamp(280.0, 360.0);
    final bool isNetwork = imagem.startsWith('http');

    return SizedBox(
      width: double.infinity,
      height: bannerHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          isNetwork
              ? Image.network(imagem, fit: BoxFit.cover)
              : Image.asset(imagem, fit: BoxFit.cover),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [
                  Colors.white,
                  Color.fromARGB(36, 255, 255, 255),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(800),
                border: Border.all(color: const Color(0x33263238), width: 1),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EventTitle extends StatelessWidget {
  final String title;
  const EventTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class EventDescription extends StatelessWidget {
  final String texto;
  const EventDescription({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final double maxHeight = (screenHeight * 0.25).clamp(120.0, 220.0);

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Text(
            texto,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}

class EventDetailsRow extends StatelessWidget {
  final String data;
  final String local;

  const EventDetailsRow({
    super.key,
    required this.data,
    required this.local,
  });

  Widget detailItem(IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: const Color(0x33263238), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 360;

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Expanded(child: detailItem(Icons.calendar_today, data))]),
          Row(children: [Expanded(child: detailItem(Icons.place, local))]),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: detailItem(Icons.calendar_today, data)),
        Expanded(child: detailItem(Icons.place, local)),
      ],
    );
  }
}
