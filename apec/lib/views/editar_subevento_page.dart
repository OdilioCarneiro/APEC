import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:apec/pages/components/image_pick_crop.dart';

import 'package:apec/pages/data/model.dart';
import 'package:apec/services/api_service.dart';

final Gradient backgroundSla = const LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color.fromARGB(255, 248, 161, 168),
    Color.fromARGB(255, 163, 219, 252),
    Color.fromARGB(255, 255, 244, 171),
  ],
);

class EditarSubEventoPage extends StatefulWidget {
  const EditarSubEventoPage({
    super.key,
    required this.eventoPai,
    required this.subevento,
    required this.categorias,
  });

  final Evento eventoPai;
  final SubEvento subevento;
  final List<String> categorias;

  @override
  State<EditarSubEventoPage> createState() => _EditarSubEventoPageState();
}

class _EditarSubEventoPageState extends State<EditarSubEventoPage> {
  static const double _btnHeight = 52.0;

  static final ButtonStyle _btnSalvarStyle = ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 81, 191, 255),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
      side: const BorderSide(
        color: Color.fromARGB(255, 69, 178, 241),
        width: 2,
      ),
    ),
  );

  static final ButtonStyle _btnCancelarStyle = ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 255, 81, 81),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
      side: const BorderSide(
        color: Color.fromARGB(255, 241, 69, 69),
        width: 2,
      ),
    ),
  );

  // ===== controllers base =====
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _localController = TextEditingController();
  final _imagemController = TextEditingController();
  final _horaController = TextEditingController();

  final _placarController = TextEditingController();
  final _fotosUrlController = TextEditingController();
  final _videoUrlController = TextEditingController();

  // ===== NOVO: controllers extra URLs =====
  final _inscricaoUrlController = TextEditingController();
  final _resultadoUrlController = TextEditingController();

  // ===== controllers cultural =====
  final _temaController = TextEditingController();
  final _artistasController = TextEditingController();

  // ===== controllers natacao =====
  final _atletaController = TextEditingController();
  final _tempoController = TextEditingController();
  final _dataProvaController = TextEditingController();

  String? _categoriaSelecionadaTexto;

  // ===== selections novas =====
  Categoria? _tipoSelecionado; // esportiva | cultural
  CategoriEspotiva? _categoriaEsportivaSelecionada;
  Genero? _generoSelecionado;

  CategoriaCultural? _categoriaCulturalSelecionada;
  ModalidadeNatacao _modalidadeNatacaoSelecionada = ModalidadeNatacao.crawl;

  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horaSelecionada = TimeOfDay.now();

  File? _selectedImage;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    final s = widget.subevento;

    _nomeController.text = s.nome;
    _descricaoController.text = s.descricao;
    _localController.text = s.local;
    _imagemController.text = s.imagem;

    // data/hora
    final parsedDate = _tryParseDate(s.data);
    if (parsedDate != null) _dataSelecionada = parsedDate;

    final parsedTime = _tryParseTime(s.hora);
    if (parsedTime != null) _horaSelecionada = parsedTime;
    _horaController.text = _formatHora(_horaSelecionada);

    // gerais
    _placarController.text = s.placar ?? '';
    _fotosUrlController.text = s.fotosUrl ?? '';
    _videoUrlController.text = s.videoUrl ?? '';

    // NOVO: urls extra
    _inscricaoUrlController.text = s.inscricaoUrl ?? '';
    _resultadoUrlController.text = s.resultadoUrl ?? '';

    // categoria de agrupamento (texto)
    final cat = (s.categoria ?? '').trim();
    if (cat.isNotEmpty && widget.categorias.contains(cat)) {
      _categoriaSelecionadaTexto = cat;
    } else if (widget.categorias.isNotEmpty) {
      _categoriaSelecionadaTexto = widget.categorias.first;
    } else {
      _categoriaSelecionadaTexto = cat.isNotEmpty ? cat : 'Nova categoria';
    }

    // ===== novos campos do modelo =====
    _tipoSelecionado = (s.tipo == Categoria.esportiva || s.tipo == Categoria.cultural) ? s.tipo : null;

    // esportivo
    _categoriaEsportivaSelecionada = s.categoriaEsportiva;
    _generoSelecionado = s.genero;

    // cultural
    _temaController.text = s.tema ?? '';
    _categoriaCulturalSelecionada = s.categoriaCultural;
    _artistasController.text = (s.artistas ?? []).join('; ');

    // natação (jogoNatacao)
    if (s.jogoNatacao != null) {
      _atletaController.text = s.jogoNatacao!.atleta;
      _modalidadeNatacaoSelecionada = s.jogoNatacao!.modalidade;
      _tempoController.text = s.jogoNatacao!.tempo;
      _dataProvaController.text = s.jogoNatacao!.data;
    }

    // Se evento pai não é ambos, força tipo consistente
    if (widget.eventoPai.categoria == Categoria.esportiva) {
      _tipoSelecionado = Categoria.esportiva;
    } else if (widget.eventoPai.categoria == Categoria.cultural) {
      _tipoSelecionado = Categoria.cultural;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _localController.dispose();
    _imagemController.dispose();
    _horaController.dispose();

    _placarController.dispose();
    _fotosUrlController.dispose();
    _videoUrlController.dispose();

    // NOVO
    _inscricaoUrlController.dispose();
    _resultadoUrlController.dispose();

    _temaController.dispose();
    _artistasController.dispose();

    _atletaController.dispose();
    _tempoController.dispose();
    _dataProvaController.dispose();

    super.dispose();
  }

  String _formatHora(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  DateTime? _tryParseDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    try {
      return DateTime.parse(s.length >= 10 ? s.substring(0, 10) : s);
    } catch (_) {
      return null;
    }
  }

  TimeOfDay? _tryParseTime(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    final parts = s.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  String? _resolveImageUrl(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    if (s.startsWith('http')) return s;

    final host = ApiService.baseUrl.replaceAll('/api', '');
    if (s.startsWith('/')) return '$host$s';
    return '$host/$s';
  }

 Future<void> _pickPhoto() async {
  final file = await ImagePickCrop.pickAndCrop(
    context: context,
    source: ImageSource.gallery,
    cropStyle: CropStyle.rectangle,
    presets: const [CropAspectRatioPreset.ratio16x9],
    lockedRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
  );

  if (file == null) return;
  setState(() {
    _selectedImage = file;
    _imagemController.text = file.path;
  });
}


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dataSelecionada = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _horaSelecionada = picked;
        _horaController.text = _formatHora(_horaSelecionada);
      });
    }
  }

  void _onChangeTipo(Categoria? tipo) {
    setState(() {
      _tipoSelecionado = tipo;

      if (tipo == Categoria.cultural) {
        // limpa esportivo
        _categoriaEsportivaSelecionada = null;
        _generoSelecionado = null;
        _atletaController.clear();
        _tempoController.clear();
        _dataProvaController.clear();
        _modalidadeNatacaoSelecionada = ModalidadeNatacao.crawl;
      } else if (tipo == Categoria.esportiva) {
        // limpa cultural
        _temaController.clear();
        _artistasController.clear();
        _categoriaCulturalSelecionada = null;
      }
    });
  }

  void _onChangeCategoriaEsportiva(CategoriEspotiva? c) {
    setState(() {
      _categoriaEsportivaSelecionada = c;
      if (c != CategoriEspotiva.natacao) {
        _atletaController.clear();
        _tempoController.clear();
        _dataProvaController.clear();
        _modalidadeNatacaoSelecionada = ModalidadeNatacao.crawl;
      }
    });
  }

  List<String> _parseLista(String raw) {
    return raw
        .split(RegExp(r'[;,]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _salvarAlteracoes() async {
    if (_loading) return;

    if (_nomeController.text.trim().isEmpty || _localController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha nome e local!')),
      );
      return;
    }

    if (_tipoSelecionado != Categoria.esportiva && _tipoSelecionado != Categoria.cultural) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o tipo do subevento (esportivo ou cultural).')),
      );
      return;
    }

    // validações específicas
    if (_tipoSelecionado == Categoria.esportiva) {
      if (_categoriaEsportivaSelecionada == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione a categoria esportiva.')),
        );
        return;
      }

      if (_categoriaEsportivaSelecionada == CategoriEspotiva.natacao) {
        if (_atletaController.text.trim().isEmpty || _tempoController.text.trim().isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Para natação, preencha atleta e tempo.')),
          );
          return;
        }
      }
    }

    if (_tipoSelecionado == Categoria.cultural) {
      if (_categoriaCulturalSelecionada == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione a categoria cultural.')),
        );
        return;
      }
    }

    final instituicaoId = await ApiService.lerInstituicaoId();
    if (instituicaoId == null || instituicaoId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa estar logado como instituição para editar subevento.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _loading = true);

      final dados = <String, dynamic>{
        'nome': _nomeController.text.trim(),
        'categoria': (_categoriaSelecionadaTexto ?? '').trim(),
        'descricao': _descricaoController.text.trim(),
        'data': _dataSelecionada.toIso8601String().substring(0, 10),

        // model: hora
        'hora': _formatHora(_horaSelecionada),

        // compat com backend antigo
        'horario': _formatHora(_horaSelecionada),

        'local': _localController.text.trim(),
        'placar': _placarController.text.trim().isEmpty ? null : _placarController.text.trim(),
        'fotosUrl': _fotosUrlController.text.trim().isEmpty ? null : _fotosUrlController.text.trim(),
        'videoUrl': _videoUrlController.text.trim().isEmpty ? null : _videoUrlController.text.trim(),

        // NOVO: urls extra
        'inscricaoUrl': _inscricaoUrlController.text.trim().isEmpty ? null : _inscricaoUrlController.text.trim(),
        'resultadoUrl': _resultadoUrlController.text.trim().isEmpty ? null : _resultadoUrlController.text.trim(),

        'instituicaoId': instituicaoId,
        'eventoPaiId': widget.eventoPai.id,

        'tipo': _tipoSelecionado!.name,
      };

      if (_tipoSelecionado == Categoria.esportiva) {
        dados['categoriaEsportiva'] = _categoriaEsportivaSelecionada!.name;
        if (_generoSelecionado != null) dados['genero'] = _generoSelecionado!.name;

        if (_categoriaEsportivaSelecionada == CategoriEspotiva.natacao) {
          dados['jogoNatacao'] = {
            'atletas': _atletaController.text.trim(),
            'modalidade': _modalidadeNatacaoSelecionada.name,
            'melhor tempo': _tempoController.text.trim(),
          };
        } else {
          dados['jogoNatacao'] = null;
        }

        // remove culturais
        dados['tema'] = null;
        dados['categoriaCultural'] = null;
        dados['artistas'] = null;
      }

      if (_tipoSelecionado == Categoria.cultural) {
        dados['tema'] = _temaController.text.trim().isEmpty ? null : _temaController.text.trim();
        dados['categoriaCultural'] = _categoriaCulturalSelecionada!.name;

        final artistas = _parseLista(_artistasController.text);
        dados['artistas'] = artistas.isEmpty ? null : artistas;

        // remove esportivos
        dados['categoriaEsportiva'] = null;
        dados['genero'] = null;
        dados['jogo'] = null;
        dados['jogoNatacao'] = null;
      }

      final atualizado = await ApiService.atualizarSubEventoSmart(
        id: widget.subevento.id,
        dados: dados,
        novaImagem: _selectedImage,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SubEvento atualizado!'), backgroundColor: Colors.green),
      );

      context.pop(atualizado);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    final double maxFormWidth = 500;
    final double horizontalPadding = screenWidth * 0.04;

    final imageUrl = (_selectedImage == null) ? _resolveImageUrl(_imagemController.text) : null;

    final List<Categoria> tiposPermitidos = widget.eventoPai.categoria == Categoria.ambos
        ? const [Categoria.esportiva, Categoria.cultural]
        : <Categoria>[widget.eventoPai.categoria];

    return Container(
      decoration: BoxDecoration(gradient: backgroundSla),
      padding: EdgeInsets.only(
        bottom: 75,
        left: horizontalPadding,
        right: horizontalPadding,
        top: 30,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxFormWidth),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Scaffold(
              backgroundColor: Colors.white,
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Editar SubEvento',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'RobotoBold',
                        color: Color(0xFF263238),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text(
                      'Foto do SubEvento',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'RobotoLight',
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),

                    GestureDetector(
                      onTap: _pickPhoto,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color.fromARGB(255, 126, 126, 126),
                              width: 2,
                            ),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    _selectedImage!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : (imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        imageUrl,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        key: ValueKey(imageUrl),
                                        errorBuilder: (_, __, ___) => Center(
                                          child: Icon(
                                            Icons.broken_image_outlined,
                                            size: 48,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.add_a_photo_rounded,
                                        size: 70,
                                        color: Colors.grey[400],
                                      ),
                                    )),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(labelText: 'Nome do SubEvento'),
                    ),

                    const SizedBox(height: 14),

                    SizedBox(
                      height: 140,
                      child: DottedBorder(
                        options: const RectDottedBorderOptions(
                          dashPattern: [3, 1.8],
                          strokeWidth: 1,
                          padding: EdgeInsets.all(18),
                          color: Color.fromARGB(255, 83, 83, 83),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: TextFormField(
                            controller: _descricaoController,
                            expands: true,
                            maxLines: null,
                            minLines: null,
                            decoration: const InputDecoration(
                              labelText: 'Descrição/Sinopse',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    DropdownMenu<String>(
                      label: const Text('Categoria'),
                      width: maxFormWidth,
                      initialSelection: _categoriaSelecionadaTexto,
                      onSelected: (v) => setState(() => _categoriaSelecionadaTexto = v),
                      dropdownMenuEntries: widget.categorias
                          .map((c) => DropdownMenuEntry<String>(value: c, label: c))
                          .toList(),
                    ),

                    const SizedBox(height: 14),

                    DropdownMenu<Categoria>(
                      label: const Text('Tipo do SubEvento'),
                      width: maxFormWidth,
                      initialSelection: _tipoSelecionado,
                      onSelected: (v) => _onChangeTipo(v),
                      dropdownMenuEntries: tiposPermitidos
                          .map((t) => DropdownMenuEntry<Categoria>(value: t, label: t.name))
                          .toList(),
                    ),

                    const SizedBox(height: 14),

                    if (_tipoSelecionado == Categoria.esportiva) ...[
                      DropdownMenu<CategoriEspotiva>(
                        label: const Text('Categoria esportiva'),
                        width: maxFormWidth,
                        initialSelection: _categoriaEsportivaSelecionada,
                        onSelected: (v) => _onChangeCategoriaEsportiva(v),
                        dropdownMenuEntries: CategoriEspotiva.values
                            .map((c) => DropdownMenuEntry<CategoriEspotiva>(value: c, label: c.name))
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      DropdownMenu<Genero>(
                        label: const Text('Gênero (opcional)'),
                        width: maxFormWidth,
                        initialSelection: _generoSelecionado,
                        onSelected: (v) => setState(() => _generoSelecionado = v),
                        dropdownMenuEntries: Genero.values
                            .map((g) => DropdownMenuEntry<Genero>(value: g, label: g.name))
                            .toList(),
                      ),
                      if (_categoriaEsportivaSelecionada == CategoriEspotiva.natacao) ...[
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _atletaController,
                          decoration: const InputDecoration(labelText: 'Atletas'),
                        ),
                        const SizedBox(height: 14),
                        DropdownMenu<ModalidadeNatacao>(
                          label: const Text('Modalidade'),
                          width: maxFormWidth,
                          initialSelection: _modalidadeNatacaoSelecionada,
                          onSelected: (v) => setState(() {
                            if (v != null) _modalidadeNatacaoSelecionada = v;
                          }),
                          dropdownMenuEntries: ModalidadeNatacao.values
                              .map((m) => DropdownMenuEntry<ModalidadeNatacao>(value: m, label: m.name))
                              .toList(),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _tempoController,
                          decoration: const InputDecoration(labelText: 'Melhor tempo (ex: 00:58.32)'),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ],

                    if (_tipoSelecionado == Categoria.cultural) ...[
                      TextFormField(
                        controller: _temaController,
                        decoration: const InputDecoration(labelText: 'Tema (opcional)'),
                      ),
                      const SizedBox(height: 14),
                      DropdownMenu<CategoriaCultural>(
                        label: const Text('Categoria cultural'),
                        width: maxFormWidth,
                        initialSelection: _categoriaCulturalSelecionada,
                        onSelected: (v) => setState(() => _categoriaCulturalSelecionada = v),
                        dropdownMenuEntries: CategoriaCultural.values
                            .map((c) => DropdownMenuEntry<CategoriaCultural>(value: c, label: c.name))
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _artistasController,
                        decoration: const InputDecoration(labelText: 'Artistas (separe por ; ou ,)'),
                      ),
                    ],

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _localController,
                      decoration: const InputDecoration(labelText: 'Local'),
                    ),

                    const SizedBox(height: 14),

                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color.fromARGB(255, 85, 85, 85)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Data: ${_dataSelecionada.day.toString().padLeft(2, '0')}/${_dataSelecionada.month.toString().padLeft(2, '0')}/${_dataSelecionada.year}",
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(2.0),
                              child: Icon(Icons.calendar_today),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    GestureDetector(
                      onTap: () => _selectTime(context),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color.fromARGB(255, 85, 85, 85)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Hora: ${_formatHora(_horaSelecionada)}'),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.access_time),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _placarController,
                      decoration: const InputDecoration(labelText: 'Placar (opcional)'),
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _fotosUrlController,
                      decoration: const InputDecoration(labelText: 'Links de Fotos (separe por ; ou vírgula)'),
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _videoUrlController,
                      decoration: const InputDecoration(labelText: 'Links de Vídeos (separe por ; ou vírgula)'),
                    ),

                    // ===== NOVO: inscrição / resultado =====
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _inscricaoUrlController,
                      decoration: const InputDecoration(labelText: 'Link de Inscrição (opcional)'),
                    ),

                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _resultadoUrlController,
                      decoration: const InputDecoration(labelText: 'Link de Resultados (opcional)'),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: _btnHeight,
                      child: ElevatedButton(
                        style: _btnSalvarStyle,
                        onPressed: _loading ? null : _salvarAlteracoes,
                        child: Text(
                          _loading ? 'Salvando...' : 'Salvar alterações',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'RobotoBold',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: _btnHeight,
                      child: ElevatedButton(
                        style: _btnCancelarStyle,
                        onPressed: () => context.pop(false),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'RobotoBold',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
