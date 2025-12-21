import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:apec/pages/data/model.dart';

class SubEventoCardComponent extends StatelessWidget {
  final SubEvento subevento;
  const SubEventoCardComponent({super.key, required this.subevento});

  bool _isHttp(String s) => s.startsWith('http://') || s.startsWith('https://');

  List<String> _splitLinks(String? raw) {
    final s = (raw ?? '').trim();
    if (s.isEmpty) return const [];
    return s
        .split(RegExp(r'[;\n,]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _dataBr(String isoDate) {
    try {
      // Esperado: "YYYY-MM-DD"
      final dt = DateTime.parse(isoDate);
      return DateFormat('dd/MM/yyyy', 'pt_BR').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  String _horaBr(String? hora) {
    final h = (hora ?? '').trim();
    // Esperado: "HH:mm" (se você salvar assim)
    return h;
  }

  Widget _buildImagem(String imagem, {BoxFit fit = BoxFit.cover}) {
    final img = imagem.trim();

    if (img.isEmpty) {
      return Container(
        color: Colors.grey.shade300,
        child: const Center(child: Icon(Icons.broken_image)),
      );
    }

    if (_isHttp(img)) {
      return Image.network(
        img,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade300,
          child: const Center(child: Icon(Icons.broken_image)),
        ),
      );
    }

    return Image.file(
      File(img),
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade300,
        child: const Center(child: Icon(Icons.broken_image)),
      ),
    );
  }

  Future<void> _abrirLink(String url) async {
    final u = url.trim();
    if (u.isEmpty) return;

    final fixed = _isHttp(u) ? u : 'https://$u';
    final uri = Uri.tryParse(fixed);
    if (uri == null) throw Exception('URL inválida: $fixed');

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) throw Exception('Não foi possível abrir: $fixed');
  }

  Widget _pillButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF263238),
        foregroundColor: Colors.white,
        elevation: 0,

        // pill maior + mais “tocável”
        minimumSize: const Size(160, 44),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),

        // Roboto Medium real via fontWeight
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }

  void _abrirSheet(BuildContext context, SubEvento s) {
    final fotosLinks = _splitLinks(s.fotosUrl);
    final videoLinks = _splitLinks(s.videoUrl);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final descController = ScrollController();
        final screenHeight = MediaQuery.of(ctx).size.height;
        final maxDescHeight = (screenHeight * 0.25).clamp(120.0, 220.0);

        final data = _dataBr(s.data);

        // Mantive sua abordagem; ideal é ter "hora" no model.
        final hora = _horaBr((s as dynamic).hora as String?);
        final dataHora = hora.isEmpty ? data : '$data • $hora';

        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.92,
          builder: (ctx, scrollController) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Material(
                color: Colors.white,
                child: Column(
                  children: [
                    // TOPO (só o puxador)
                    Container(
                      width: double.infinity,
                      height: 40,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          width: 55,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),

                    // CORPO
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        children: [
                          AspectRatio(
                            aspectRatio: 26 / 19,
                            child: _buildImagem(s.imagem, fit: BoxFit.fill),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.nome,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Roboto',
                                    color: Color(0xFF263238),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // DESCRIÇÃO (seu modelo com Scrollbar + maxHeight)
                                if (s.descricao.trim().isNotEmpty)
                                  Container(
                                    constraints: BoxConstraints(maxHeight: maxDescHeight),
                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      controller: descController,
                                      child: SingleChildScrollView(
                                        controller: descController,
                                        child: Text(
                                          s.descricao,
                                          style: const TextStyle(
                                            color: Colors.black87,
                                            fontSize: 16,
                                            height: 1.3,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 16),

                                // DATA (BR) + HORA (lado a lado)
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 21, color: Color(0xFF546E7A)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        dataHora,
                                        style: const TextStyle(
                                          color: Color(0xFF546E7A),
                                          fontSize: 21,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // LOCAL (embaixo)
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 21, color: Color(0xFF546E7A)),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        s.local,
                                        style: const TextStyle(
                                          color: Color(0xFF546E7A),
                                          fontSize: 21,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                if ((s.placar ?? '').trim().isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    s.placar!.trim(),
                                    style: const TextStyle(
                                      color: Color(0xFF546E7A),
                                      fontSize: 14,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 16),

                                if (fotosLinks.isEmpty && videoLinks.isEmpty)
                                  Text(
                                    'Sem links cadastrados.',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  )
                                else
                                  Wrap(
                                    spacing: 30,
                                    runSpacing: 10,
                                    children: [
                                      for (int i = 0; i < fotosLinks.length; i++)
                                        _pillButton(
                                          label: fotosLinks.length == 1 ? 'fotos' : 'fotos ${i + 1}',
                                          icon: Icons.photo_library_outlined,
                                          onPressed: () => _abrirLink(fotosLinks[i]),
                                        ),
                                      for (int i = 0; i < videoLinks.length; i++)
                                        _pillButton(
                                          label: videoLinks.length == 1 ? 'Assistir' : 'Assistir ${i + 1}',
                                          icon: Icons.play_arrow_rounded,
                                          onPressed: () => _abrirLink(videoLinks[i]),
                                        ),
                                    ],
                                  ),

                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = subevento;

    return Card(
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: 305,
        height: 140,
        child: Stack(
          children: [
            Positioned.fill(child: _buildImagem(s.imagem)),
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(0, 0, 0, 0),
                      Color.fromARGB(160, 0, 0, 0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.nome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(s.data, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(
                      s.local,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: () => _abrirSheet(context, s)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
