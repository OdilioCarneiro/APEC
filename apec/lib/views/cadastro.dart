import 'package:flutter/material.dart';
import 'package:apec/pages/data/model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:apec/services/api_service.dart';

class Cadastro extends StatelessWidget {
  const Cadastro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro de Evento',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          cancelButtonStyle: TextButton.styleFrom(foregroundColor: const Color(0xFF1565C0)),
          confirmButtonStyle: TextButton.styleFrom(foregroundColor: const Color(0xFF1565C0)),
          todayBackgroundColor: const WidgetStatePropertyAll(Colors.transparent),
          todayForegroundColor: const WidgetStatePropertyAll(Colors.blue),
          todayBorder: const BorderSide(color: Colors.blue),
          dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return Colors.blue;
            return null;
          }),
          dayOverlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused) ||
                states.contains(WidgetState.pressed)) {
              return Colors.blue;
            }
            return null;
          }),
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: Colors.white,
          dayPeriodColor:  Colors.blue,
          dayPeriodTextColor: Colors.blue ,
          dialBackgroundColor: const Color.fromARGB(255, 210, 210, 210) ,
          dialHandColor: const Color.fromARGB(255, 91, 181, 255) ,
          dialTextColor: const Color.fromARGB(255, 0, 0, 0),
          entryModeIconColor: Colors.blue ,
          hourMinuteColor: const Color.fromARGB(255, 210, 210, 210),
          hourMinuteTextColor: const Color.fromARGB(255, 0, 0, 0),
          cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: Colors.blue,),
          confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: Colors.blue,),
        ),
        dropdownMenuTheme: const DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
            surfaceTintColor: WidgetStatePropertyAll<Color>(Colors.white),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.blue,
          selectionColor: Color(0x3390CAF9),
          selectionHandleColor: Colors.blue,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
      home: const CadastroEventoScreen(),
    );
  }
}

final Gradient backgroundSla = const LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color.fromARGB(255, 248, 161, 168), // FA4050
    Color.fromARGB(255, 163, 219, 252), // 59B0E3
    Color.fromARGB(255, 255, 244, 171), // F5E15F
  ],
);

class CadastroEventoScreen extends StatefulWidget {
  const CadastroEventoScreen({super.key});
  @override
  State<CadastroEventoScreen> createState() => _CadastroEventoScreenState();
}

class _CadastroEventoScreenState extends State<CadastroEventoScreen> {
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _localController = TextEditingController();
  final _imagemController = TextEditingController();
  final _temaController = TextEditingController();
  final _artistasController = TextEditingController();
  final _horarioController = TextEditingController();

  Categoria? _categoriaSelecionada;
  CategoriEspotiva? _categoriaEsportivaSelecionada;
  Genero? _generoSelecionado;
  CategoriaCultural? _categoriaCulturalSelecionada;

  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horaSelecionada = TimeOfDay.now();

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _horarioController.text = _formatHora(_horaSelecionada);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _localController.dispose();
    _imagemController.dispose();
    _temaController.dispose();
    _artistasController.dispose();
    _horarioController.dispose();
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
          child: child!,
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

  void _salvarEvento() async {
    // Validação básica de campos obrigatórios
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

    // NÃO valida mais a imagem (agora é opcional)

    try {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Salvando evento...')),
      );

      // Monta os dados (Map<String, dynamic> para aceitar null/outros tipos se precisar)
      final dados = <String, dynamic>{
        'nome': _nomeController.text,
        'categoria': _categoriaSelecionada!.name,
        'descricao': _descricaoController.text,
        'data': _dataSelecionada.toIso8601String().substring(0, 10),
        'horario': _formatHora(_horaSelecionada),
        'local': _localController.text,
      };

      if (_categoriaSelecionada == Categoria.esportiva) {
        if (_categoriaEsportivaSelecionada != null) {
          dados['categoriaEsportiva'] = _categoriaEsportivaSelecionada!.name;
        }
        if (_generoSelecionado != null) {
          dados['genero'] = _generoSelecionado!.name;
        }
      }

      if (_categoriaSelecionada == Categoria.cultural) {
        dados['tema'] = _temaController.text;
        dados['categoriaCultural'] = _categoriaCulturalSelecionada?.name ?? '';

        final artistas = _artistasController.text
            .split(';')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        // Se quiser mandar array no JSON ou string no Multipart, 
        // o ideal é mandar string (separada por ;) para simplificar o Multipart
        dados['artistas'] = artistas.join(';'); 
      }

      // Chama o método inteligente
      final response = await ApiService.criarEventoSmart(
        dados: dados,
        imagem: _selectedImage, // passa a imagem (pode ser null)
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento salvo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      // Limpa formulário
      _nomeController.clear();
      _descricaoController.clear();
      _localController.clear();
      _imagemController.clear();
      _temaController.clear();
      _artistasController.clear();
      _horarioController.clear();
      setState(() {
        _categoriaSelecionada = null;
        _categoriaEsportivaSelecionada = null;
        _generoSelecionado = null;
        _categoriaCulturalSelecionada = null;
        _selectedImage = null;
        _dataSelecionada = DateTime.now();
        _horaSelecionada = TimeOfDay.now();
      });

      Navigator.pop(context, response);

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: backgroundSla),
      padding: const EdgeInsets.only(bottom: 75, left: 10, right: 10, top: 30),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 20),
              Transform.translate(
                offset: const Offset(5, -10),
                child: const Text(
                  'Foto do Evento',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'RobotoLight',
                    color: Colors.grey,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _pickPhoto,
                child: Transform.translate(
                  offset: const Offset(0, -10),
                  child: Container(
                    width: 346,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color.fromARGB(255, 126, 126, 126), width: 2),
                    ),
                    child: _selectedImage == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_rounded, size: 70, color: Colors.grey[400]),
                                const SizedBox(height: 0),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.fill,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(
                width: 400,
                child: TextFormField(
                  controller: _nomeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
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
                      borderSide: const BorderSide(color: Color.fromARGB(255, 83, 83, 83)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7.0),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 77, 168, 221), width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: 340,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Descrição/Sinopse',
                        labelStyle: TextStyle(
                          fontSize: 16,
                          fontFamily: 'RobotoMedium',
                          color: Color.fromARGB(221, 151, 151, 151),
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Color.fromARGB(255, 77, 168, 221),
                          fontFamily: 'RobotoMedium',
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
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
                width: 400,
                dropdownMenuEntries:
                    Categoria.values.map((c) => DropdownMenuEntry<Categoria>(value: c, label: c.name)).toList(),
              ),
              const SizedBox(height: 14),
              if (_categoriaSelecionada == Categoria.esportiva) ...[
                DropdownMenu<CategoriEspotiva>(
                  label: const Text('Tipo esportivo'),
                  initialSelection: _categoriaEsportivaSelecionada,
                  onSelected: (c) => setState(() => _categoriaEsportivaSelecionada = c),
                  width: 400,
                  dropdownMenuEntries: CategoriEspotiva.values
                      .map((c) => DropdownMenuEntry<CategoriEspotiva>(value: c, label: c.name))
                      .toList(),
                ),
                const SizedBox(height: 14),
                DropdownMenu<Genero>(
                  label: const Text('Gênero'),
                  initialSelection: _generoSelecionado,
                  onSelected: (g) => setState(() => _generoSelecionado = g),
                  width: 400,
                  dropdownMenuEntries:
                      Genero.values.map((g) => DropdownMenuEntry<Genero>(value: g, label: g.name)).toList(),
                ),
              ],
              if (_categoriaSelecionada == Categoria.cultural) ...[
                TextFormField(
                  controller: _temaController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Tema',
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
                      borderSide: const BorderSide(color: Color.fromARGB(255, 77, 168, 221), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownMenu<CategoriaCultural>(
                  label: const Text('Tipo cultural'),
                  initialSelection: _categoriaCulturalSelecionada,
                  onSelected: (c) => setState(() => _categoriaCulturalSelecionada = c),
                  width: 320,
                  dropdownMenuEntries: CategoriaCultural.values
                      .map((c) => DropdownMenuEntry<CategoriaCultural>(value: c, label: c.name))
                      .toList(),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _artistasController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Artistas (separe por ";")',
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
                      borderSide: const BorderSide(color: Color.fromARGB(255, 77, 168, 221), width: 2),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: 400,
                child: TextFormField(
                  controller: _localController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Local',
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
                      borderSide: const BorderSide(color: Color.fromARGB(255, 77, 168, 221), width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
                  SizedBox(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color.fromARGB(255, 85, 85, 85), width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Data: ${_dataSelecionada.day.toString().padLeft(2, '0')}/${_dataSelecionada.month.toString().padLeft(2, '0')}/${_dataSelecionada.year}",
                                style: const TextStyle(fontFamily: 'Roboto'),
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
                  ),
                   const SizedBox(height: 14),
                  SizedBox(
                    child: GestureDetector(
                      onTap: () => _selectTime(context),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color.fromARGB(255, 85, 85, 85), width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Hora: ${_formatHora(_horaSelecionada)}',
                                style: const TextStyle(fontFamily: 'Roboto'),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.access_time),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 24),
              SizedBox(
                width: 400,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 81, 191, 255),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                      side: const BorderSide(color: Color.fromARGB(255, 69, 178, 241), width: 2),
                    ),
                  ),
                  onPressed: _salvarEvento,
                  child: const Text(
                    'Salvar Evento',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'RobotoBold',
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget inputCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: child,
    );
  }
}