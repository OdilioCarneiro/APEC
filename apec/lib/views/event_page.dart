import 'package:flutter/material.dart';
import 'package:apec/pages/data/model.dart';

class EventPage extends StatelessWidget {
  final Evento evento;
  const EventPage({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;

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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: fundoEvento,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Banner ocupa toda a largura, sem padding lateral
              EventBanner(imagem: evento.imagem),

              // Apenas espaçamento embaixo do banner
              const SizedBox(height: 24),

              // Conteúdo rolável com padding lateral
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: 24,
                  ),
                  children: [
                    // Título
                    EventTitle(title: evento.nome),

                    const SizedBox(height: 8),

                    // Data / horário / local
                    EventDetailsRow(
                      data: evento.data,
                      local: evento.local,
                    ),

                    const SizedBox(height: 12),

                    // Descrição
                    EventDescription(texto: evento.descricao),
                    const SizedBox(height: 16),

                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Banner ----------

class EventBanner extends StatelessWidget {
  final String imagem;
  const EventBanner({super.key, required this.imagem});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bannerHeight = (screenWidth * 0.56).clamp(280.0, 360.0);
    final bool isNetwork = imagem.startsWith('http');

    return SizedBox(
      width: double.infinity,
      height: bannerHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Imagem de fundo cobrindo toda a largura
          isNetwork
              ? Image.network(imagem, fit: BoxFit.cover)
              : Image.asset(imagem, fit: BoxFit.cover),

          // Gradiente branco de baixo para o centro
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [
                  
                  Colors.white,
                  const Color.fromARGB(36, 255, 255, 255),
                  
                ],
              ),
            ),
          ),

          // Botão de voltar
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(800),
                border: Border.all(color: const Color(0x33263238), width: 1),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Título ----------

class EventTitle extends StatelessWidget {
  final String title;
  const EventTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

// ---------- Descrição ----------

class EventDescription extends StatelessWidget {
  final String texto;
  const EventDescription({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final double maxHeight =
        (screenHeight * 0.25).clamp(120.0, 220.0);

    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Text(
            texto,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              height: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- Data / horário / local ----------

class EventDetailsRow extends StatelessWidget {
  final String data;
  final String local;
  const EventDetailsRow({
    super.key,
    required this.data,
    required this.local,
  });

  Widget detailItem(IconData icon, String text) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: const Color(0x33263238),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 360;

    if (isNarrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: detailItem(Icons.calendar_today, data)),
            ],
          ),
          Row(
            children: [
              Expanded(child: detailItem(Icons.place, local)),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: detailItem(Icons.calendar_today, data)),
        Expanded(child: detailItem(Icons.place, local)),
      ],
    );
  }
}


