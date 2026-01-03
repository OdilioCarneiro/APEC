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
      final dt = DateTime.parse(isoDate.length >= 10 ? isoDate.substring(0, 10) : isoDate);
      return DateFormat('dd/MM/yyyy', 'pt_BR').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  String _horaBr(String hora) => hora.trim();

  String _tipoLabel(Categoria? tipo) {
    if (tipo == null) return 'Não informado';
    switch (tipo) {
      case Categoria.esportiva:
        return 'Esportivo';
      case Categoria.cultural:
        return 'Cultural';
      case Categoria.ambos:
        return 'Ambos';
    }
  }

  IconData _tipoIcon(Categoria? tipo) {
    if (tipo == Categoria.esportiva) return Icons.sports_soccer;
    if (tipo == Categoria.cultural) return Icons.theater_comedy_outlined;
    return Icons.category_outlined;
  }

  Color _tipoColor(Categoria? tipo) {
    if (tipo == Categoria.esportiva) return const Color.fromARGB(255, 192, 192, 21);
    if (tipo == Categoria.cultural) return const Color.fromARGB(255, 154, 27, 27);
    return const Color(0xFF455A64);
  }

  Widget _buildImagem(String imagem, {BoxFit fit = BoxFit.cover}) {
    final img = imagem.trim();

    if (img.isEmpty) {
      return Container(
        color: Colors.grey.shade300,
        child: const Center(child: Icon(Icons.broken_image_outlined)),
      );
    }

    if (_isHttp(img)) {
      return Image.network(
        img,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade300,
          child: const Center(child: Icon(Icons.broken_image_outlined)),
        ),
      );
    }

    return Image.file(
      File(img),
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey.shade300,
        child: const Center(child: Icon(Icons.broken_image_outlined)),
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
    Color? background,
  }) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: background,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        textStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Card(
      elevation: 0,
      color: const Color(0xFFF6F7F8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: child,
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {bool soft = false}) {
    final color = soft ? const Color(0xFF607D8B) : const Color(0xFF263238);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF607D8B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 14,
              height: 1.25,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      side: BorderSide(color: color.withValues(alpha: 0.25)),
      backgroundColor: color.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      visualDensity: VisualDensity.compact,
    );
  }

  void _abrirSheet(BuildContext context, SubEvento s) {
    final fotosLinks = _splitLinks(s.fotosUrl);
    final videoLinks = _splitLinks(s.videoUrl);

    // NOVO: links únicos
    final inscricaoLink = (s.inscricaoUrl ?? '').trim();
    final resultadoLink = (s.resultadoUrl ?? '').trim();

    final data = _dataBr(s.data);
    final hora = _horaBr(s.hora);
    final dataHora = hora.isEmpty ? data : '$data • $hora';

    final tipo = s.tipo;
    final tipoColor = _tipoColor(tipo);

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,

      // antes estava 100% transparente; com scrim leve fica melhor [web:66]
      barrierColor: const Color(0x66000000),

      showDragHandle: false,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 1,
          minChildSize: 0.45,
          maxChildSize: 1,
          builder: (ctx, scrollController) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Material(
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    AspectRatio(
                      aspectRatio: 26 / 17,
                      child: _buildImagem(s.imagem, fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.nome,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Roboto',
                              color: Color(0xFF263238),
                            ),
                          ),
                          const SizedBox(height: 10),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _chip(icon: _tipoIcon(tipo), label: _tipoLabel(tipo), color: tipoColor),
                              if ((s.categoriaEsportiva != null) && tipo == Categoria.esportiva)
                                _chip(
                                  icon: Icons.sports,
                                  label: s.categoriaEsportiva!.name,
                                  color: const Color.fromARGB(255, 192, 186, 21),
                                ),
                              if ((s.categoriaCultural != null) && tipo == Categoria.cultural)
                                _chip(
                                  icon: Icons.palette_outlined,
                                  label: s.categoriaCultural!.name,
                                  color: const Color.fromARGB(255, 154, 27, 27),
                                ),
                              if ((s.genero != null) && tipo == Categoria.esportiva)
                                _chip(
                                  icon: Icons.person_outline,
                                  label: s.genero!.name,
                                  color: const Color.fromARGB(255, 192, 186, 21),
                                ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          _sectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoRow(Icons.calendar_today_outlined, dataHora, soft: true),
                                const SizedBox(height: 10),
                                _infoRow(Icons.location_on_outlined, s.local, soft: true),
                              ],
                            ),
                          ),

                          if (s.descricao.trim().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Descrição',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: Color(0xFF263238),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    s.descricao,
                                    style: const TextStyle(
                                      color: Color(0xFF37474F),
                                      fontSize: 14,
                                      height: 1.35,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (tipo == Categoria.cultural) ...[
                            const SizedBox(height: 12),
                            _sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Detalhes culturais',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: Color(0xFF263238),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if ((s.tema ?? '').trim().isNotEmpty)
                                    _infoRow(Icons.topic_outlined, (s.tema ?? '').trim()),
                                  if ((s.tema ?? '').trim().isNotEmpty) const SizedBox(height: 8),
                                  if ((s.artistas ?? const <String>[]).isNotEmpty)
                                    _infoRow(Icons.people_outlined, (s.artistas ?? []).join(', ')),
                                ],
                              ),
                            ),
                          ],

                          if (tipo == Categoria.esportiva) ...[
                            const SizedBox(height: 12),
                            _sectionCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Detalhes esportivos',
                                    style: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: Color(0xFF263238),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if ((s.placar ?? '').trim().isNotEmpty)
                                    _infoRow(Icons.scoreboard_outlined, 'Placar: ${(s.placar ?? '').trim()}'),
                                  if (s.jogoNatacao != null && s.categoriaEsportiva == CategoriEspotiva.natacao) ...[
                                    if ((s.placar ?? '').trim().isNotEmpty) const SizedBox(height: 10),
                                    _infoRow(Icons.person_outline, 'Atletas: ${s.jogoNatacao!.atleta}'),
                                    const SizedBox(height: 8),
                                    _infoRow(Icons.pool_outlined, 'Modalidade: ${s.jogoNatacao!.modalidade.name}'),
                                    const SizedBox(height: 8),
                                    _infoRow(Icons.timer_outlined, 'Melhor tempo: ${s.jogoNatacao!.tempo}'),
                                  ],
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),

                          // LINKS (agora com inscrição e resultado)
                          _sectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Links',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    color: Color(0xFF263238),
                                  ),
                                ),
                                const SizedBox(height: 10, width: double.infinity),

                                if (fotosLinks.isEmpty &&
                                    videoLinks.isEmpty &&
                                    inscricaoLink.isEmpty &&
                                    resultadoLink.isEmpty)
                                  Text(
                                    'Sem links cadastrados.',
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                  )
                                else
                                  SizedBox(
                                    width: double.infinity,
                                    child: Wrap(
                                      alignment: WrapAlignment.spaceBetween,
                                      runSpacing: 12,
                                      spacing: 12,
                                      children: [
                                        for (int i = 0; i < fotosLinks.length; i++)
                                          _pillButton(
                                            label: fotosLinks.length == 1 ? 'Fotos' : 'Fotos ${i + 1}',
                                            icon: Icons.photo_library_outlined,
                                            background: const Color(0xFF263238).withValues(alpha: 0.08),
                                            onPressed: () => _abrirLink(fotosLinks[i]),
                                          ),
                                        for (int i = 0; i < videoLinks.length; i++)
                                          _pillButton(
                                            label: videoLinks.length == 1 ? 'Assistir' : 'Assistir ${i + 1}',
                                            icon: Icons.play_arrow_rounded,
                                            background: const Color(0xFF263238).withValues(alpha: 0.08),
                                            onPressed: () => _abrirLink(videoLinks[i]),
                                          ),

                                        if (inscricaoLink.isNotEmpty)
                                          _pillButton(
                                            label: 'Inscrição',
                                            icon: Icons.how_to_reg_outlined,
                                            background: const Color(0xFF263238).withValues(alpha: 0.08),
                                            onPressed: () => _abrirLink(inscricaoLink),
                                          ),

                                        if (resultadoLink.isNotEmpty)
                                          _pillButton(
                                            label: 'Resultados',
                                            icon: Icons.emoji_events_outlined,
                                            background: const Color(0xFF263238).withValues(alpha: 0.08),
                                            onPressed: () => _abrirLink(resultadoLink),
                                          ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),
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

    final data = _dataBr(s.data);
    final hora = s.hora.trim();
    final dataHora = hora.isEmpty ? data : '$data • $hora';

    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                      Color.fromARGB(180, 0, 0, 0),
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
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dataHora,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
