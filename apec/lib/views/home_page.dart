import 'package:flutter/material.dart';
import 'dart:io';
import 'package:apec/pages/data/model.dart';
import 'package:apec/services/api_service.dart';
import 'cadastro.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _eventosAPI;

  @override
  void initState() {
    super.initState();
    _eventosAPI = ApiService.listarEventos();
  }

  Future<void> _abrirCadastro() async {
    final resultado = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (_) => const CadastroEventoScreen()),
    );
    // Atualizar lista de eventos após cadastro
    if (resultado != null) {
      setState(() {
        _eventosAPI = ApiService.listarEventos();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCadastro,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _eventosAPI,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erro ao carregar eventos:\n${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _eventosAPI = ApiService.listarEventos();
                    }),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final eventos = snapshot.data ?? [];

          if (eventos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_note, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Nenhum evento encontrado'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _abrirCadastro,
                    child: const Text('Criar primeiro evento'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 18,
              runSpacing: 18,
              children: eventos.map((e) {
                final evento = Evento.fromAPI(e);
                return EventoCard(evento: evento);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}

// Um card simples com os dados principais

class EventoCard extends StatelessWidget {
  final Evento evento;
  const EventoCard({required this.evento, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 290,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (evento.imagem.isNotEmpty)
              Builder(builder: (context) {
                final String img = evento.imagem;
                if (img.toLowerCase().startsWith('http')) {
                  return Image.network(
                    img,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => const SizedBox(
                      height: 110,
                      child: Center(child: Icon(Icons.broken_image)),
                    ),
                  );
                }
                // assume local file path
                try {
                  final file = File(img);
                  if (file.existsSync()) {
                    return Image.file(
                      file,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => const SizedBox(
                        height: 110,
                        child: Center(child: Icon(Icons.broken_image)),
                      ),
                    );
                  }
                } catch (_) {}
                return const SizedBox(
                  height: 110,
                  child: Center(child: Icon(Icons.broken_image)),
                );
              }),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(evento.nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  if (evento.data.isNotEmpty && evento.horario.isNotEmpty)
                    Text('${evento.data} • ${evento.horario}', style: const TextStyle(color: Colors.grey)),
                  Text(evento.local, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  if (evento.descricao.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        evento.descricao,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
