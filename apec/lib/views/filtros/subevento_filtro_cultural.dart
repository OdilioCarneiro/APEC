import 'package:flutter/material.dart';
import 'package:apec/pages/data/model.dart';
import 'package:apec/services/api_service.dart';
import 'package:apec/pages/components/card_subevento.dart';

class SubEventosPorCategoriaCulturalPage extends StatefulWidget {
  final String categoriaCulturalKey; 
  final String titulo;

  const SubEventosPorCategoriaCulturalPage({
    super.key,
    required this.categoriaCulturalKey,
    required this.titulo,
  });

  @override
  State<SubEventosPorCategoriaCulturalPage> createState() =>
      _SubEventosPorCategoriaCulturalPageState();
}

class _SubEventosPorCategoriaCulturalPageState
    extends State<SubEventosPorCategoriaCulturalPage> {
  late Future<List<dynamic>> _subEventosAPI;

  @override
  void initState() {
    super.initState();


    _subEventosAPI = ApiService.listarSubEventosCulturais(
      categoriaCultural: widget.categoriaCulturalKey.trim(),
    );


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
                      _subEventosAPI = ApiService.listarSubEventosCulturais(
                        categoriaCultural: widget.categoriaCulturalKey.trim(),
                      );


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

          final keyDesejada = widget.categoriaCulturalKey.trim();


          final filtrados = todos.where((s) {
            if (s.tipo != Categoria.cultural) return false;
            return s.categoriaCultural?.name == keyDesejada;
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
