import 'package:flutter/material.dart';
import 'package:apec/pages/data/model.dart';
import 'package:apec/services/api_service.dart';
import 'package:apec/pages/components/card_subevento.dart';

class SubEventosPorCategoriaEsportivaPage extends StatefulWidget {
  /// Ex: 'natacao', 'basquete', 'voleibol'... (tem que bater com CategoriEspotiva.name)
  final String categoriaEsportivaKey;

  /// Texto do AppBar (ex: 'Natação')
  final String titulo;

  const SubEventosPorCategoriaEsportivaPage({
    super.key,
    required this.categoriaEsportivaKey,
    required this.titulo,
  });

  @override
  State<SubEventosPorCategoriaEsportivaPage> createState() =>
      _SubEventosPorCategoriaEsportivaPageState();
}

class _SubEventosPorCategoriaEsportivaPageState
    extends State<SubEventosPorCategoriaEsportivaPage> {
  late Future<List<dynamic>> _subEventosAPI;

  @override
  void initState() {
    super.initState();

    // Pode buscar tudo esportivo; o filtro final é local (garante 100%)
    _subEventosAPI = ApiService.listarSubEventosEsportivos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: FutureBuilder<List<dynamic>>(
        future: _subEventosAPI,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Erro: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _subEventosAPI = ApiService.listarSubEventosEsportivos();
                    }),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final todos = (snapshot.data ?? [])
              .whereType<Map<String, dynamic>>()
              .map(SubEvento.fromAPI)
              .toList();

          final keyDesejada = widget.categoriaEsportivaKey.trim();

          final filtrados = todos.where((s) {
            if (s.tipo != Categoria.esportiva) return false;
            return s.categoriaEsportiva?.name == keyDesejada;
          }).toList();

          if (filtrados.isEmpty) {
            return const Center(child: Text('Nenhum subevento encontrado'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: filtrados.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              return SubEventoCardComponent(subevento: filtrados[i]);
            },
          );
        },
      ),
    );
  }
}
