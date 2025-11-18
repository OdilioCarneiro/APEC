import 'package:flutter/material.dart';
import 'dart:io';
import 'package:apec/pages/data/model.dart';
import 'cadastro.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Evento> _eventos = [];

  Future<void> _abrirCadastro() async {
    final Evento? novo = await Navigator.push<Evento>(
      context,
      MaterialPageRoute(builder: (_) => const CadastroEventoScreen()),
    );
    if (novo != null) {
      setState(() => _eventos.add(novo)); // Adiciona e atualiza os cards
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 18,
          runSpacing: 18,
          children: _eventos.map((e) => EventoCard(evento: e)).toList(),
        ),
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
