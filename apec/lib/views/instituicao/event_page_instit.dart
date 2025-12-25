import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:apec/pages/data/model.dart';
import 'package:apec/services/api_service.dart';
import 'package:apec/pages/components/card_subevento.dart';
import 'package:apec/views/event_page.dart';

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

  bool _actingSubevento = false;

  final List<_SubeventoLinha> _linhas = [];

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

        // limpa linhas antigas
        for (final l in _linhas) {
          l.controller.dispose();
        }
        _linhas.clear();

        // 1) monta TODAS as linhas a partir de categoriasSubeventos
        final rawCats = _evento.categoriasSubeventos;
        if (rawCats.isEmpty) {
          _linhas.add(_SubeventoLinha(titulo: 'Nova categoria'));
        } else {
          for (final item in rawCats) {
            final t = item.toString().trim();
            if (t.isEmpty) continue;
            if (_indexLinhaPorTitulo(t) == -1) {
              _linhas.add(_SubeventoLinha(titulo: t));
            }
          }
        }

        // 2) encaixa subeventos nas linhas existentes (CRIANDO linha se precisar)
        for (final s in subs) {
          final cat = (s.categoria ?? '').trim();
          final titulo = cat.isEmpty ? 'Nova categoria' : cat;

          var idx = _indexLinhaPorTitulo(titulo);
          if (idx == -1) {
            _linhas.add(_SubeventoLinha(titulo: titulo));
            idx = _linhas.length - 1;
          }

          _linhas[idx].subeventos.add(s);
        }

        if (_linhas.isEmpty) {
          _linhas.add(_SubeventoLinha(titulo: 'Nova categoria'));
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
  // LONG PRESS SUBEVENTO (EDIT/DELETE)
  // ===========================

  Future<void> _onLongPressSubevento(SubEvento sub) async {
    if (_actingSubevento) return;

    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar subevento'),
                onTap: () => Navigator.pop(ctx, 'edit'),
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Apagar subevento'),
                onTap: () => Navigator.pop(ctx, 'delete'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    if (action == 'edit') {
      final categorias = _linhas
          .map((l) => l.controller.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      final result = await context.push(
        '/editar_subevento',
        extra: {
          'eventoPai': _evento,
          'subevento': sub,
          'categorias': categorias,
        },
      );

      if (!mounted) return;
      if (result != null) {
        _changed = true;
        await _carregarSubeventosDoBackend();
      }
      return;
    }

    if (action == 'delete') {
      await _apagarSubevento(sub);
    }
  }

  Future<void> _apagarSubevento(SubEvento sub) async {
    final id = sub.id;
    if (id.trim().isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar subevento?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Apagar')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() => _actingSubevento = true);
      await ApiService.deletarSubEvento(id);
      _changed = true;
      await _carregarSubeventosDoBackend();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao apagar subevento: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _actingSubevento = false);
    }
  }

  // ===========================
  // HELPERS (nomes únicos / validação)
  // ===========================

  String _gerarTituloUnico(String base) {
    final existentes = _linhas
        .map((l) => l.controller.text.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toSet();

    if (!existentes.contains(base.toLowerCase())) return base;

    int n = 2;
    while (existentes.contains('${base.toLowerCase()} $n')) {
      n++;
    }
    return '$base $n';
  }

  bool _temDuplicatasIgnorandoCase() {
    final titulos = _linhas.map((l) => l.controller.text.trim()).where((t) => t.isNotEmpty).toList();

    final seen = <String>{};
    for (final t in titulos) {
      final k = t.toLowerCase();
      if (!seen.add(k)) return true;
    }
    return false;
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
    return _linhas.map((l) => l.controller.text.trim()).where((t) => t.isNotEmpty).toList();
  }

  Future<void> _salvarCategoriasAgora() async {
    if (_savingCategorias) return;

    final eventoId = _evento.id;
    if (eventoId == null || eventoId.isEmpty) return;

    if (_temDuplicatasIgnorandoCase()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Existem categorias com o mesmo nome. Renomeie para nomes diferentes.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
      final titulo = _gerarTituloUnico('Nova categoria');
      _linhas.add(_SubeventoLinha(titulo: titulo));
      _changed = true;
    });

    unawaited(_salvarCategoriasAgora());
  }

  void _removerLinha(int index) {
    if (_linhas.length <= 1) return;

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
    if (_savingCategorias) return;

    final novo = novoTitulo.trim();
    final antigo = linha.tituloSalvo.trim();

    if (novo.isEmpty) {
      linha.controller.text = antigo;
      return;
    }
    if (antigo.isNotEmpty && novo.toLowerCase() == antigo.toLowerCase()) {
      linha.controller.text = novo;
      return;
    }

    final novoKey = novo.toLowerCase();
    final existeOutroIgual = _linhas.any((l) {
      if (identical(l, linha)) return false;
      return l.controller.text.trim().toLowerCase() == novoKey;
    });

    if (existeOutroIgual) {
      linha.controller.text = antigo;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Já existe uma categoria com esse nome.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
      linha.controller.text = novo;

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
                        Positioned(
                          top: 12,
                          right: 12,
                          child: _CircleIconButton(
                            icon: Icons.edit,
                            onPressed: () => context.push(
                              '/login/editar_evento',
                              extra: evento,
                            ),
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
                                  canDelete: _linhas.length > 1,
                                  onTapAdd: () => _adicionarSubeventoNaLinha(i),
                                  onDelete: () => _removerLinha(i),
                                  onTituloChanged: (_) {
                                    _changed = true;
                                  },
                                  onTituloSubmitted: (txt) => _renomearCategoria(_linhas[i], txt),
                                  onLongPressSubevento: _onLongPressSubevento,
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
            if (_savingCategorias || _actingSubevento)
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

  final void Function(SubEvento sub) onLongPressSubevento;

  const _LinhaSubeventos({
    required this.linha,
    required this.canDelete,
    required this.onTapAdd,
    required this.onDelete,
    required this.onTituloChanged,
    required this.onTituloSubmitted,
    required this.onLongPressSubevento,
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
                    final atual = linha.controller.text.trim();
                    final salvo = linha.tituloSalvo.trim();
                    if (atual.toLowerCase() != salvo.toLowerCase()) {
                      onTituloSubmitted(atual);
                    }
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

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onLongPress: () => onLongPressSubevento(sub),
                  child: SubEventoCardComponent(subevento: sub),
                ),
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
