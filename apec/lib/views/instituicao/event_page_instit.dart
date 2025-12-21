import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:apec/pages/data/model.dart';
import 'package:apec/services/api_service.dart';

// AJUSTE ESTE IMPORT PARA O NOME REAL DO ARQUIVO:
// import 'package:apec/pages/components/subevento_card.dart';
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

  final List<_SubeventoLinha> _linhas = [
    _SubeventoLinha(titulo: 'Subeventos'),
  ];

  @override
  void initState() {
    super.initState();
    _evento = widget.evento;
  }

  @override
  void dispose() {
    for (final l in _linhas) {
      l.controller.dispose();
    }
    super.dispose();
  }

  Future<void> _criarNovaLinhaComLoading() async {
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _linhas.add(_SubeventoLinha(titulo: 'Nova categoria'));
      _changed = true;
    });
  }

  void _removerLinha(int index) {
    setState(() {
      _linhas[index].controller.dispose();
      _linhas.removeAt(index);
      _changed = true;
    });
  }

  Future<void> _adicionarSubeventoNaLinha(int indexLinha) async {
    final categorias = _linhas
        .map((l) => l.controller.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final dynamic result = await context.push<dynamic>(
      '/subevento',
      extra: {
        'eventoPai': _evento,
        'categoria': _linhas[indexLinha].controller.text,
        'categorias': categorias,
      },
    );

    if (!mounted || result == null) return;

    SubEvento sub;
    if (result is SubEvento) {
      sub = result;
    } else if (result is Map<String, dynamic>) {
      sub = SubEvento.fromAPI(result);
    } else {
      return;
    }

    setState(() {
      _linhas[indexLinha].subeventos.add(sub);
      _changed = true;
    });
  }

  Future<void> _editarEvento() async {
    final bool? edited = await context.push<bool>(
      '/login/editar_evento',
      extra: _evento,
    );

    if (!mounted) return;

    if (edited == true) {
      _changed = true;
      try {
        final json = await ApiService.obterEvento(_evento.id ?? '');
        if (!mounted) return;
        setState(() => _evento = Evento.fromAPI(json));
      } catch (_) {}
    }
  }

  Future<void> _excluirEvento() async {
    if (_deleting) return;

    final id = _evento.id;
    if (id == null || id.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento sem ID. Não foi possível excluir.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir evento?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() => _deleting = true);

      await ApiService.deletarEvento(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento excluído com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      _changed = true;
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  void _voltar() {
    context.pop(_changed);
  }

  @override
  Widget build(BuildContext context) {
    final evento = _evento;
    final screenHeight = MediaQuery.of(context).size.height;

    final Gradient fundoEvento =
        (evento.categoria == Categoria.esportiva)
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
        _voltar();
      },
      child: Scaffold(
        body: Container(
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
                        onPressed: _voltar,
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _CircleIconButton(
                        icon: Icons.edit,
                        onPressed: _editarEvento,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _criarNovaLinhaComLoading,
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

                        ...List.generate(_linhas.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _LinhaSubeventos(
                              linha: _linhas[i],
                              onTapAdd: () => _adicionarSubeventoNaLinha(i),
                              onDelete: () => _removerLinha(i),
                            ),
                          );
                        }),

                        const SizedBox(height: 18),
                        Text(
                          'Puxe para baixo para criar uma nova categoria.',
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                        ),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 255, 81, 81),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 241, 69, 69),
                                  width: 2,
                                ),
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
      ),
    );
  }
}

class _LinhaSubeventos extends StatelessWidget {
  final _SubeventoLinha linha;
  final VoidCallback onTapAdd;
  final VoidCallback onDelete;

  const _LinhaSubeventos({
    required this.linha,
    required this.onTapAdd,
    required this.onDelete,
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
              child: TextField(
                controller: linha.controller,
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
            const SizedBox(width: 8),
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

              // ÚNICO card de subevento usado aqui:
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

  _SubeventoLinha({required String titulo})
      : controller = TextEditingController(text: titulo),
        subeventos = [];
}
