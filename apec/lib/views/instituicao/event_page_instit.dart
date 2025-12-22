import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:apec/pages/data/model.dart';
import 'package:apec/services/api_service.dart';

// ÚNICO card de subevento usado aqui:
import 'package:apec/pages/components/card_subevento.dart';

import 'package:apec/views/event_page.dart'; // EventBanner, EventTitle, EventDetailsRow, EventDescription

class EventosPageInstit extends StatefulWidget {
  final Evento evento;
  const EventosPageInstit({super.key, required this.evento});

  @override
  State<EventosPageInstit> createState() => _EventosPageInstitState();
}

class _EventosPageInstitState extends State<EventosPageInstit> {
  late Evento _evento;

  bool _changed = false;
  bool _deleting = false;
  bool _loadingSubeventos = false;

  Timer? _debounceSalvarCategorias;
  bool _savingCategorias = false;

  final List<_SubeventoLinha> _linhas = [
    _SubeventoLinha(titulo: 'Subeventos'),
  ];

  @override
  void initState() {
    super.initState();
    _evento = widget.evento;
    scheduleMicrotask(_carregarSubeventosDoBackend);
  }

  @override
  void dispose() {
    _debounceSalvarCategorias?.cancel();
    for (final l in _linhas) {
      l.controller.dispose();
    }
    super.dispose();
  }

  // ===========================
  // BACKEND -> UI
  // ===========================

  Future<void> _carregarSubeventosDoBackend() async {
    final eventoId = _evento.id;
    if (eventoId == null || eventoId.isEmpty) return;

    try {
      if (mounted) setState(() => _loadingSubeventos = true);

      final eventoJson = await ApiService.obterEvento(eventoId);
      final eventoAtualizado = Evento.fromAPI(eventoJson);

      final list = await ApiService.listarSubEventos(eventoPaiId: eventoId);
      final subs = list
          .whereType<Map>()
          .map((e) => SubEvento.fromAPI(Map<String, dynamic>.from(e)))
          .toList();

      if (!mounted) return;

      setState(() {
        _evento = eventoAtualizado;

        for (final l in _linhas) {
          l.controller.dispose();
        }
        _linhas.clear();

        // base fixa
        _linhas.add(_SubeventoLinha(titulo: 'Subeventos'));

        // categorias do evento (mesmo vazias)
        final rawCats = _evento.categoriasSubeventos;
        for (final item in rawCats) {
          final t = item.toString().trim();
          if (t.isNotEmpty && t.toLowerCase() != 'subeventos') {
            if (_indexLinhaPorTitulo(t) == -1) {
              _linhas.add(_SubeventoLinha(titulo: t));
            }
          }
        }

        // agrupa subeventos nas linhas (NÃO cria linha nova se vier categoria não listada)
        for (final s in subs) {
          final cat = (s.categoria ?? '').trim().isEmpty
              ? 'Subeventos'
              : s.categoria!.trim();
          final idx = _indexLinhaPorTitulo(cat);

          if (idx == -1) {
            // se vier categoria “antiga” que não existe mais no array do evento,
            // não cria nova row: joga na base.
            _linhas[0].subeventos.add(s);
          } else {
            _linhas[idx].subeventos.add(s);
          }
        }

        if (_linhas.isEmpty) {
          _linhas.add(_SubeventoLinha(titulo: 'Subeventos'));
        }
      });
    } finally {
      if (mounted) setState(() => _loadingSubeventos = false);
    }
  }

  int _indexLinhaPorTitulo(String titulo) {
    final t = titulo.trim().toLowerCase();
    for (int i = 0; i < _linhas.length; i++) {
      if (_linhas[i].controller.text.trim().toLowerCase() == t) return i;
    }
    return -1;
  }

  // ===========================
  // CATEGORIAS -> SALVAR NO EVENTO (add/remover)
  // ===========================

  void _queueSalvarCategorias() {
    _debounceSalvarCategorias?.cancel();
    _debounceSalvarCategorias = Timer(const Duration(milliseconds: 600), () {
      unawaited(_salvarCategoriasAgora());
    });
  }

  List<String> _titulosCategoriasUi() {
    final titulos = _linhas
        .map((l) => l.controller.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    titulos.removeWhere((t) => t.toLowerCase() == 'subeventos');
    titulos.insert(0, 'Subeventos');

    final seen = <String>{};
    final unique = <String>[];
    for (final t in titulos) {
      final key = t.toLowerCase();
      if (seen.add(key)) unique.add(t);
    }

    return unique;
  }

  Future<void> _salvarCategoriasAgora() async {
    if (_savingCategorias) return;

    final eventoId = _evento.id;
    if (eventoId == null || eventoId.isEmpty) return;

    final titulos = _titulosCategoriasUi();

    try {
      if (mounted) setState(() => _savingCategorias = true);

      final json = await ApiService.atualizarCategoriasSubeventos(
        eventoId: eventoId,
        categoriasTitulos: titulos,
      );

      if (!mounted) return;

      setState(() {
        _evento = Evento.fromAPI(json);
        _changed = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível salvar as categorias: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _savingCategorias = false);
    }
  }

  void _adicionarLinha() {
    setState(() {
      _linhas.add(_SubeventoLinha(titulo: 'Nova categoria'));
      _changed = true;
    });

    // cria a row no Evento (persistência) sem mexer em subeventos
    unawaited(_salvarCategoriasAgora());
  }

  void _removerLinha(int index) {
    if (_linhas.length <= 1) return;
    if (index == 0) return;

    setState(() {
      _linhas[index].controller.dispose();
      _linhas.removeAt(index);
      _changed = true;
    });

    _queueSalvarCategorias();
  }

  // ===========================
  // RENOMEAR (EVENTO + SUBEVENTOS)
  // ===========================

  Future<void> _renomearCategoria(_SubeventoLinha linha, String novoTitulo) async {
    final novo = novoTitulo.trim();
    final antigo = linha.tituloSalvo.trim();

    if (novo.isEmpty) {
      linha.controller.text = antigo;
      return;
    }
    if (antigo.isNotEmpty && novo.toLowerCase() == antigo.toLowerCase()) return;

    final eventoId = _evento.id;
    if (eventoId == null || eventoId.isEmpty) return;

    _debounceSalvarCategorias?.cancel();

    try {
      if (mounted) setState(() => _savingCategorias = true);

      final json = await ApiService.renomearCategoriaSubeventos(
        eventoId: eventoId,
        antiga: antigo,
        nova: novo,
      );

      linha.tituloSalvo = novo;

      if (!mounted) return;
      setState(() {
        _evento = Evento.fromAPI(json);
        _changed = true;
      });

      await _carregarSubeventosDoBackend();
    } catch (e) {
      linha.controller.text = antigo;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao renomear categoria: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _savingCategorias = false);
    }
  }

  // ===========================
  // NOVO SUBEVENTO
  // ===========================

  Future<void> _adicionarSubeventoNaLinha(int indexLinha) async {
    if (indexLinha < 0 || indexLinha >= _linhas.length) return;

    final categorias = _linhas
        .map((l) => l.controller.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final dynamic result = await context.push<dynamic>(
      '/subevento',
      extra: {
        'eventoPai': _evento,
        'categoria': _linhas[indexLinha].controller.text.trim(),
        'categorias': categorias,
      },
    );

    if (!mounted || result == null) return;

    await _carregarSubeventosDoBackend();
    if (!mounted) return;
    setState(() => _changed = true);
  }

  // ===========================
  // EXCLUIR / SAIR
  // ===========================

  Future<void> _excluirEvento() async {
    if (_deleting) return;

    final id = _evento.id;
    if (id == null || id.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir evento?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() => _deleting = true);
      await ApiService.deletarEvento(id);
      if (!mounted) return;
      _changed = true;
      context.pop(true);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _sairSalvando() async {
    _debounceSalvarCategorias?.cancel();
    if (_changed) {
      await _salvarCategoriasAgora();
    }
    if (!mounted) return;
    context.pop(_changed);
  }

  // ===========================
  // UI
  // ===========================

  @override
  Widget build(BuildContext context) {
    final evento = _evento;
    final screenHeight = MediaQuery.of(context).size.height;

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

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        unawaited(_sairSalvando());
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(gradient: fundoEvento),
              child: SafeArea(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        EventBanner(imagem: evento.imagem),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: _CircleIconButton(
                            icon: Icons.arrow_back,
                            onPressed: () => unawaited(_sairSalvando()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _carregarSubeventosDoBackend,
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
                            if (_loadingSubeventos)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: OutlinedButton(
                                onPressed: _adicionarLinha,
                                child: const Text('Nova categoria'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...List.generate(_linhas.length, (i) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _LinhaSubeventos(
                                  linha: _linhas[i],
                                  canDelete: _linhas.length > 1 && i != 0,
                                  onTapAdd: () => _adicionarSubeventoNaLinha(i),
                                  onDelete: () => _removerLinha(i),
                                  onTituloChanged: (_) {
                                    _changed = true; // não salva/renomeia aqui
                                  },
                                  onTituloSubmitted: (txt) =>
                                      _renomearCategoria(_linhas[i], txt),
                                ),
                              );
                            }),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 255, 81, 81),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                onPressed: _deleting ? null : _excluirEvento,
                                child: Text(
                                  _deleting ? 'Excluindo...' : 'Excluir evento',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontFamily: 'RobotoBold',
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_savingCategorias)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x55000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LinhaSubeventos extends StatelessWidget {
  final _SubeventoLinha linha;
  final bool canDelete;
  final VoidCallback onTapAdd;
  final VoidCallback onDelete;
  final ValueChanged<String> onTituloChanged;
  final ValueChanged<String> onTituloSubmitted;

  const _LinhaSubeventos({
    required this.linha,
    required this.canDelete,
    required this.onTapAdd,
    required this.onDelete,
    required this.onTituloChanged,
    required this.onTituloSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) {
                    onTituloSubmitted(linha.controller.text);
                  }
                },
                child: TextField(
                  controller: linha.controller,
                  onChanged: onTituloChanged,
                  onSubmitted: onTituloSubmitted,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF263238),
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.only(bottom: 4),
                    hintText: 'Nome da categoria',
                    hintStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0x33263238), width: 1),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0x33263238), width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF263238), width: 1.4),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (canDelete)
              _CircleIconButton(
                icon: Icons.delete_outline,
                onPressed: onDelete,
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 1 + linha.subeventos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == 0) return _AddCard(onTap: onTapAdd);
              final sub = linha.subeventos[index - 1];
              return SubEventoCardComponent(subevento: sub);
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

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white70,
        borderRadius: BorderRadius.circular(800),
        border: Border.all(color: const Color(0x33263238), width: 1),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }
}

class _SubeventoLinha {
  final TextEditingController controller;
  final List<SubEvento> subeventos;
  String tituloSalvo;

  _SubeventoLinha({required String titulo})
      : controller = TextEditingController(text: titulo),
        subeventos = [],
        tituloSalvo = titulo;
}
