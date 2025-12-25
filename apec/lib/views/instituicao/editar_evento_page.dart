import 'dart:io';

import 'package:flutter/material.dart';
import 'package:apec/pages/data/model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:apec/services/api_service.dart';
import 'package:go_router/go_router.dart';

final Gradient backgroundSla = const LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color.fromARGB(255, 248, 161, 168),
    Color.fromARGB(255, 163, 219, 252),
    Color.fromARGB(255, 255, 244, 171),
  ],
);

class EditarEventoPage extends StatefulWidget {
  final Evento evento;

  const EditarEventoPage({super.key, required this.evento});

  @override
  State<EditarEventoPage> createState() => _EditarEventoPageState();
}

class _EditarEventoPageState extends State<EditarEventoPage> {
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _localController = TextEditingController();
  final _imagemController = TextEditingController();
  final _horarioController = TextEditingController();

  Categoria? _categoriaSelecionada;

  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horaSelecionada = TimeOfDay.now();

  File? _selectedImage;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.evento;

    _nomeController.text = e.nome;
    _descricaoController.text = e.descricao;
    _localController.text = e.local;
    _horarioController.text = e.horario;

    _categoriaSelecionada = e.categoria;

    if (e.data.isNotEmpty) {
      try {
        _dataSelecionada = DateTime.parse(e.data);
      } catch (_) {}
    }
    _horaSelecionada = _parseHora(e.horario);

    // opcional: se você quiser manter o texto com a imagem atual (útil em debug)
    _imagemController.text = e.imagem;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _localController.dispose();
    _imagemController.dispose();
    _horarioController.dispose();
    super.dispose();
  }

  String _formatHora(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay _parseHora(String h) {
    try {
      final parts = h.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return TimeOfDay.now();
    }
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
        _horarioController.text = _formatHora(_horaSelecionada);
      });
    }
  }

  Future<void> _salvarEdicao() async {
    if (_loading) return;

    if (_categoriaSelecionada == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma categoria!')),
      );
      return;
    }

    if (_nomeController.text.isEmpty || _localController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha nome e local!')),
      );
      return;
    }

    final instituicaoId = await ApiService.lerInstituicaoId();
    if (instituicaoId == null || instituicaoId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você precisa estar logado como instituição para editar evento.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _loading = true);

      final dados = <String, dynamic>{
        'nome': _nomeController.text,
        'categoria': _categoriaSelecionada!.name, // esportiva | cultural | ambos
        'descricao': _descricaoController.text,
        'data': _dataSelecionada.toIso8601String().substring(0, 10),
        'horario': _formatHora(_horaSelecionada),
        'local': _localController.text,
        'instituicaoId': instituicaoId,
        // IMPORTANTE: tema/artistas/gênero/categoriaEsportiva/categoriaCultural saíram do Evento.
      };

      // IMAGEM:
      // Se o seu ApiService.atualizarEvento ainda for "JSON puro", isso aqui NÃO vai atualizar arquivo.
      // A forma correta é o ApiService aceitar multipart quando _selectedImage != null.
      // Aqui a tela só envia o path no campo imagem como fallback.
      if (_selectedImage == null) {
        // mantém a imagem atual ou o que tiver no controller (se você usar)
        dados['imagem'] = widget.evento.imagem;
      } else {
        dados['imagem'] = _imagemController.text; // fallback (path local)
      }

      await ApiService.atualizarEvento(widget.evento.id ?? '', dados);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar: $e'),
          backgroundColor: Colors.red,
        ),
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
                      'Foto do Evento',
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
                              : (widget.evento.imagem.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        widget.evento.imagem,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
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
                      decoration: InputDecoration(
                        labelText: 'Nome do Evento',
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
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 83, 83, 83),
                          ),
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

                    DropdownMenu<Categoria>(
                      label: const Text('Categoria'),
                      initialSelection: _categoriaSelecionada,
                      onSelected: (c) => setState(() => _categoriaSelecionada = c),
                      width: maxFormWidth,
                      dropdownMenuEntries: Categoria.values
                          .map((c) => DropdownMenuEntry<Categoria>(value: c, label: c.name))
                          .toList(),
                    ),

                    const SizedBox(height: 14),

                    // REMOVIDO:
                    // - campos esportivos/culturais, pois agora pertencem ao SubEvento [memory:conversation_history:5]

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
                          border: Border.all(
                            color: const Color.fromARGB(255, 85, 85, 85),
                          ),
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
                          border: Border.all(
                            color: const Color.fromARGB(255, 85, 85, 85),
                          ),
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

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 81, 191, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: const BorderSide(
                              color: Color.fromARGB(255, 69, 178, 241),
                              width: 2,
                            ),
                          ),
                        ),
                        onPressed: _loading ? null : _salvarEdicao,
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
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 255, 81, 81),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                            side: const BorderSide(
                              color: Color.fromARGB(255, 241, 69, 69),
                              width: 2,
                            ),
                          ),
                        ),
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
