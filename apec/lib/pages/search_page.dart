import 'package:flutter/material.dart';
import 'package:apec/services/api_service.dart';
import 'package:apec/pages/components/card.dart'; // EventCardComponent
import 'package:apec/pages/components/card_subevento.dart'; // SubEventoCardComponent
import 'package:apec/pages/data/model.dart';

class SearchPage extends StatefulWidget {
  final String termoInicial;

  const SearchPage({super.key, required this.termoInicial});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<Map<String, dynamic>> _buscaFuture;

  @override
  void initState() {
    super.initState();
    _buscaFuture = ApiService.pesquisar(widget.termoInicial);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Busca: "${widget.termoInicial}"'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _buscaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final eventos = (data['eventos'] as List).map((e) => Evento.fromAPI(e)).toList();
          final subeventos = (data['subeventos'] as List).map((s) => SubEvento.fromAPI(s)).toList();
          final instituicoes = data['instituicoes'] as List;

          if (eventos.isEmpty && subeventos.isEmpty && instituicoes.isEmpty) {
            return const Center(child: Text("Nenhum resultado encontrado."));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (instituicoes.isNotEmpty) ...[
                const Text("Instituições", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...instituicoes.map((i) => Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundImage: NetworkImage(i['imagem'] ?? '')),
                    title: Text(i['nome']),
                    subtitle: Text(i['campus'] ?? ''),
                  ),
                )),
                const SizedBox(height: 20),
              ],
              
              if (eventos.isNotEmpty) ...[
                const Text("Eventos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...eventos.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: EventCardComponent(evento: e),
                )),
                const SizedBox(height: 20),
              ],

              if (subeventos.isNotEmpty) ...[
                const Text("Jogos / Atividades", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: subeventos.length,
                    separatorBuilder: (_,__) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => SubEventoCardComponent(subevento: subeventos[i]),
                  ),
                )
              ],
            ],
          );
        },
      ),
    );
  }
}
