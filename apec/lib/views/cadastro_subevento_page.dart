import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:go_router/go_router.dart';

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

class CadastroSubEvento extends StatelessWidget {
  const CadastroSubEvento({
    super.key,
    required this.eventoPai,
    required this.categoriaInicial,
    required this.categorias,
  });

  final Evento eventoPai;
  final String categoriaInicial;
  final List<String> categorias;

  @override
  Widget build(BuildContext context) {
    return CadastroSubEventoScreen(
      eventoPai: eventoPai,
      categoriaInicial: categoriaInicial,
      categorias: categorias,
    );
  }
}

class CadastroSubEventoScreen extends StatefulWidget {
  const CadastroSubEventoScreen({
    super.key,
    required this.eventoPai,
    required this.categoriaInicial,
    required this.categorias,
  });

  final Evento eventoPai;
  final String categoriaInicial;
  final List<String> categorias;

  @override
  State<CadastroSubEventoScreen> createState() => _CadastroSubEventoScreenState();
}

class _CadastroSubEventoScreenState extends State<CadastroSubEventoScreen> {
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
  final _horaController = TextEditingController(); // era _horarioController

  final _placarController = TextEditingController();
  final _fotosUrlController = TextEditingController();
  final _videoUrlController = TextEditingController();

  // ===== NOVO: controllers extra URLs =====
  final _inscricaoUrlController = TextEditingController();
  final _resultadoUrlController = TextEditingController();

  // ===== controllers cultural =====
  final _temaController = TextEditingController();
  final _artistasController = TextEditingController();

  // ===== controllers natacao (jogoNatacao) =====
  final _atletaController = TextEditingController();
  final _tempoController = TextEditingController();
  final _dataProvaController = TextEditingController(); // opcional

  // ===== selections =====
  String? _categoriaSelecionadaTexto;

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

    _horaController.text = _formatHora(_horaSelecionada);

    final inicial = widget.categoriaInicial.trim();
    _categoriaSelecionadaTexto =
        inicial.isNotEmpty ? inicial : (widget.categorias.isNotEmpty ? widget.categorias.first : 'Nova categoria');

    if (widget.categorias.isNotEmpty && !widget.categorias.contains(_categoriaSelecionadaTexto)) {
      _categoriaSelecionadaTexto = widget.categorias.first;
    }

    // Heurística: se o evento pai é esportiva/cultural, já pré-seleciona o tipo.
    // Se for ambos, deixa null para escolher.
    if (widget.eventoPai.categoria == Categoria.esportiva) {
      _tipoSelecionado = Categoria.esportiva;
    } else if (widget.eventoPai.categoria == Categoria.cultural) {
      _tipoSelecionado = Categoria.cultural;
    } else {
      _tipoSelecionado = null; // Categoria.ambos
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

  String _formatHora(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;
    setState(() {
      _selectedImage = File(img.path);
      _imagemController.text = img.path;
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
        _categoriaEsportivaSelecionada = null;
        _generoSelecionado = null;
        _atletaController.clear();
        _tempoController.clear();
        _dataProvaController.clear();
        _modalidadeNatacaoSelecionada = ModalidadeNatacao.crawl;
      } else if (tipo == Categoria.esportiva) {
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

  Future<void> _salvarSubEvento() async {
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
        const SnackBar(content: Text('Por favor, selecione o tipo do subevento (esportivo ou cultural).')),
      );
      return;
    }

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
          content: Text('Você precisa estar logado como instituição para criar subevento.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _loading = true);

      final dados = <String, dynamic>{
        'nome': _nomeController.text.trim(),
        'categoria': (_categoriaSelecionadaTexto ?? '').trim(), // grupo
        'descricao': _descricaoController.text.trim(),
        'data': _dataSelecionada.toIso8601String().substring(0, 10),
        'hora': _formatHora(_horaSelecionada),
        'local': _localController.text.trim(),
        'placar': _placarController.text.trim().isEmpty ? null : _placarController.text.trim(),
        'fotosUrl': _fotosUrlController.text.trim().isEmpty ? null : _fotosUrlController.text.trim(),
        'videoUrl': _videoUrlController.text.trim().isEmpty ? null : _videoUrlController.text.trim(),

        // NOVO
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
            'atleta': _atletaController.text.trim(),
            'modalidade': _modalidadeNatacaoSelecionada.name,
            'tempo': _tempoController.text.trim(),
            'data': _dataProvaController.text.trim().isNotEmpty
                ? _dataProvaController.text.trim()
                : _dataSelecionada.toIso8601String().substring(0, 10),
          };
        }
      }

      if (_tipoSelecionado == Categoria.cultural) {
        dados['tema'] = _temaController.text.trim().isEmpty ? null : _temaController.text.trim();
        dados['categoriaCultural'] = _categoriaCulturalSelecionada!.name;

        final artistas = _parseLista(_artistasController.text);
        if (artistas.isNotEmpty) dados['artistas'] = artistas;
      }

      final criado = await ApiService.criarSubEventoSmart(
        dados: dados,
        imagem: _selectedImage,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SubEvento salvo com sucesso!'), backgroundColor: Colors.green),
      );

      context.pop(criado);
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
                          child: _selectedImage == null
                              ? Center(
                                  child: Icon(
                                    Icons.add_a_photo_rounded,
                                    size: 70,
                                    color: Colors.grey[400],
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    _selectedImage!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                        labelText: 'Nome do SubEvento',
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'RobotoMedium',
                          color: Color.fromARGB(221, 151, 151, 151),
                        ),
                        floatingLabelStyle: const TextStyle(
                          color: Color.fromARGB(255, 77, 168, 221),
                          fontFamily: 'RobotoMedium',
                          fontSize: 16,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(color: Color.fromARGB(255, 83, 83, 83)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(7.0),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 77, 168, 221),
                            width: 2,
                          ),
                        ),
                      ),
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
                      dropdownMenuEntries: widget.categorias.map((c) => DropdownMenuEntry<String>(value: c, label: c)).toList(),
                    ),

                    const SizedBox(height: 14),

                    DropdownMenu<Categoria>(
                      label: const Text('Tipo do SubEvento'),
                      width: maxFormWidth,
                      initialSelection: _tipoSelecionado,
                      onSelected: (v) => _onChangeTipo(v),
                      dropdownMenuEntries:
                          tiposPermitidos.map((t) => DropdownMenuEntry<Categoria>(value: t, label: t.name)).toList(),
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
                        dropdownMenuEntries: Genero.values.map((g) => DropdownMenuEntry<Genero>(value: g, label: g.name)).toList(),
                      ),
                      if (_categoriaEsportivaSelecionada == CategoriEspotiva.natacao) ...[
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _atletaController,
                          decoration: const InputDecoration(labelText: 'Atleta'),
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
                          decoration: const InputDecoration(labelText: 'Tempo (ex: 00:58.32)'),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _dataProvaController,
                          decoration: const InputDecoration(
                            labelText: 'Data da prova (opcional, AAAA-MM-DD)',
                          ),
                        ),
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
                        decoration: const InputDecoration(
                          labelText: 'Artistas (separe por ; ou ,)',
                        ),
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
                      decoration: const InputDecoration(labelText: 'Links de Fotos (separe por ; ou ,)'),
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _videoUrlController,
                      decoration: const InputDecoration(labelText: 'Links de Vídeos (separe por ; ou ,)'),
                    ),

                    // NOVO
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
                        onPressed: _loading ? null : _salvarSubEvento,
                        child: Text(
                          _loading ? 'Salvando...' : 'Salvar SubEvento',
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
