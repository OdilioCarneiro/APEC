import 'dart:async';
import 'package:flutter/material.dart';

import 'package:apec/pages/data/model.dart';
import 'package:apec/services/api_service.dart';
import 'package:apec/pages/components/card_subevento.dart';

// IMPORTS NOVOS
import 'package:apec/pages/components/custom_search_bar.dart';
import 'package:apec/pages/search_page.dart';

class EventPage extends StatefulWidget {
  final Evento evento;
  const EventPage({super.key, required this.evento});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  static const String _categoriaPadrao = 'Nova categoria';
  late Future<_EventPageData> _future;
  
  // 1. Controlador
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = _carregarTudo();
  }

  // 2. Navegação
  void _navegarParaPesquisa(String termo) {
    if (termo.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(termoInicial: termo),
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _carregarTudo());
    await _future;
  }

  Future<_EventPageData> _carregarTudo() async {
    final eventoId = widget.evento.id;
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
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text("Erro")),
            body: Center(child: Text("Erro: ${snap.error}")),
          );
        }

        final data = snap.data!;
        final evento = data.evento;
        final subs = data.subeventos;

        // Lógica de gradiente (mantida igual a sua original)
        final Gradient fundoEvento = switch (evento.categoria) {
          Categoria.esportiva => LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [const Color.fromARGB(255, 255, 255, 255), Colors.yellow.shade300],
            ),
          Categoria.cultural => const LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 255, 110, 110)],
            ),
          Categoria.ambos => const LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 110, 170, 255)],
            ),
        };

        // Lógica de agrupamento (mantida)
        final Map<String, List<SubEvento>> grupos = {};
        final rawCats = evento.categoriasSubeventos;
        if (rawCats.isEmpty) {
          grupos[_categoriaPadrao] = [];
        } else {
          final seen = <String>{};
          for (final cat in rawCats) {
            final titulo = cat.toString().trim();
            if (titulo.isEmpty) continue;
            final key = titulo.toLowerCase();
            if (seen.add(key)) {
              grupos.putIfAbsent(titulo, () => []);
            }
          }
          if (grupos.isEmpty) grupos[_categoriaPadrao] = [];
        }
        for (final s in subs) {
          final cat = (s.categoria ?? '').trim();
          final titulo = cat.isEmpty ? _categoriaPadrao : cat;
          grupos.putIfAbsent(titulo, () => []);
          grupos[titulo]!.add(s);
        }
        final categoriasOrdenadas = grupos.keys.toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(gradient: fundoEvento),
            child: SafeArea(
              child: Column(
                children: [
                  // 3. BARRA DE PESQUISA AQUI (FIXA NO TOPO)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: CustomSearchBar(
                      controller: _searchController,
                      onSubmitted: _navegarParaPesquisa,
                      hintText: "Buscar neste evento...",
                    ),
                  ),

                  // 4. Conteúdo com Scroll
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 24),
                        children: [
                          EventBanner(imagem: evento.imagem),
                          const SizedBox(height: 24),
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
                          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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

// ... As classes auxiliares (_EventPageData, _LinhaSubeventosReadOnly, EventBanner, etc) continuam iguais ao seu arquivo original.
class _EventPageData {
  final Evento evento;
  final List<SubEvento> subeventos;
  const _EventPageData({required this.evento, required this.subeventos});
}

class _LinhaSubeventosReadOnly extends StatelessWidget {
  final String titulo;
  final List<SubEvento> subeventos;
  const _LinhaSubeventosReadOnly({required this.titulo, required this.subeventos});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF263238))),
        const SizedBox(height: 10),
        if (subeventos.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0x33263238))),
            child: Text('Sem cards nesta categoria.', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: subeventos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => SubEventoCardComponent(subevento: subeventos[i]),
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
    final bool isNetwork = imagem.startsWith('http');
    return SizedBox(
      width: double.infinity, height: 280,
      child: Stack(fit: StackFit.expand, children: [
        isNetwork ? Image.network(imagem, fit: BoxFit.cover) : Image.asset(imagem, fit: BoxFit.cover),
        Positioned(top: 12, left: 12, child: CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)))),
      ]),
    );
  }
}

class EventTitle extends StatelessWidget { final String title; const EventTitle({super.key, required this.title}); @override Widget build(BuildContext context) => Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)); }
class EventDescription extends StatelessWidget { final String texto; const EventDescription({super.key, required this.texto}); @override Widget build(BuildContext context) => Text(texto, style: const TextStyle(fontSize: 16)); }
class EventDetailsRow extends StatelessWidget { final String data, local; const EventDetailsRow({super.key, required this.data, required this.local}); @override Widget build(BuildContext context) => Row(children: [Icon(Icons.calendar_today, size: 16), SizedBox(width: 4), Text(data), SizedBox(width: 16), Icon(Icons.place, size: 16), SizedBox(width: 4), Text(local)]); }
