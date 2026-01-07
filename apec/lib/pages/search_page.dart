import 'package:flutter/material.dart';
import 'package:apec/services/api_service.dart';
import 'package:apec/pages/components/card.dart'; 
import 'package:apec/pages/components/card_subevento.dart';
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
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: Text('Busca: "${widget.termoInicial}"'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
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

          final data = snapshot.data ?? {};

          // 1. LISTAS COM PROTEÇÃO (Se vier null, usa lista vazia [])
          final eventosList = data['eventos'] as List? ?? [];
          final subeventosList = data['subeventos'] as List? ?? [];
          final instituicoesList = data['instituicoes'] as List? ?? [];

          // 2. CONVERSÃO SEGURA PARA OBJETOS
          final eventos = eventosList.map((e) => Evento.fromAPI(e)).toList();
          final subeventos = subeventosList.map((s) => SubEvento.fromAPI(s)).toList();

          if (eventos.isEmpty && subeventos.isEmpty && instituicoesList.isEmpty) {
            return const Center(child: Text("Nenhum resultado encontrado."));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- INSTITUIÇÕES ---
              if (instituicoesList.isNotEmpty) ...[
                const Text("Instituições", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...instituicoesList.map((i) => Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundImage: NetworkImage(i['imagem'] ?? '')),
                    title: Text(i['nome'] ?? ''),
                    subtitle: Text(i['campus'] ?? ''),
                  ),
                )),
                const SizedBox(height: 24),
              ],
              
              // --- EVENTOS ---
              if (eventos.isNotEmpty) ...[
                const Text("Eventos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...eventos.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EventCardComponent(evento: e),
                )),
                const SizedBox(height: 24),
              ],

              // --- SUBEVENTOS (JOGOS) ---
              if (subeventos.isNotEmpty) ...[
                const Text("Jogos e Atividades", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                // Carrossel Horizontal
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: subeventos.length,
                    separatorBuilder: (_,__) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => SizedBox(
                      width: 280, // Largura fixa para ficar bonito
                      child: SubEventoCardComponent(subevento: subeventos[i]),
                    ),
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
