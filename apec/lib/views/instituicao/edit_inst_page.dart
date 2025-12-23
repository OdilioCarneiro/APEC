import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:go_router/go_router.dart';
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

class EditarInstPage extends StatefulWidget {
  final Map<String, dynamic>? initial;
  const EditarInstPage({super.key, this.initial});

  @override
  State<EditarInstPage> createState() => _EditarInstPageState();
}

class _EditarInstPageState extends State<EditarInstPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeInstController = TextEditingController();
  final _campusController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  String? _instId;
  String? _imagemUrlAtual;

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  void _prefill() {
    final data = widget.initial;
    if (data == null) return;

    _instId = (data['id'] ?? '').toString();
    _nomeInstController.text = (data['nome'] ?? '').toString();
    _campusController.text = (data['campus'] ?? '').toString();
    _bioInstControllerSafeSet((data['bio'] ?? '').toString());
    _emailController.text = (data['email'] ?? '').toString();

    final img = (data['imagemUrl'] ?? '').toString().trim();
    _imagemUrlAtual = img.isEmpty ? null : img;
  }

  void _bioInstControllerSafeSet(String value) {
    _bioController.text = value;
  }

  @override
  void dispose() {
    _nomeInstController.dispose();
    _campusController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => _imageFile = File(picked.path));
  }

  void _snack(String msg, {Color? bg}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: bg),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          color: Color.fromARGB(255, 81, 191, 255),
          width: 2,
        ),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Future<void> _salvar() async {
    if (_loading || _deleting) return;
    if (!_formKey.currentState!.validate()) return;

    if ((_senhaController.text.isNotEmpty || _confirmarSenhaController.text.isNotEmpty) &&
        _senhaController.text != _confirmarSenhaController.text) {
      _snack('As senhas não coincidem.', bg: Colors.red);
      return;
    }

    if (_instId == null || _instId!.isEmpty) {
      _snack('ID da instituição não encontrado.', bg: Colors.red);
      return;
    }

    try {
      setState(() => _loading = true);

      final dados = <String, dynamic>{
        'nome': _nomeInstController.text.trim(),
        'campus': _campusController.text.trim(),
        'bio': _bioController.text.trim(),
        'email': _emailController.text.trim(),
      };

      if (_senhaController.text.trim().isNotEmpty) {
        dados['senha'] = _senhaController.text;
      }

      await ApiService.atualizarInstituicaoSmart(
        instituicaoId: _instId!,
        dados: dados,
        novaImagem: _imageFile,
      );

      if (!mounted) return;
      _snack('Perfil atualizado!', bg: Colors.green);
      context.pop(true);
    } catch (e) {
      _snack('Erro ao salvar: $e', bg: Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmarExcluir() async {
    if (_deleting || _instId == null || _instId!.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir instituição?'),
        content: const Text('Essa ação não pode ser desfeita. Todos os dados serão removidos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() => _deleting = true);

      await ApiService.deletarInstituicao(_instId!);

      if (!mounted) return;
      _snack('Instituição excluída.', bg: Colors.red);
      // fecha a tela de edição, e quem chamou pode tratar logout/navegação
      context.pop(true);
    } catch (e) {
      _snack('Erro ao excluir: $e', bg: Colors.red);
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Widget _buildProfileAvatar() {
    final gradientColors = <Color>[
      const Color(0xFFFA4050),
      const Color(0xFF59B0E3),
      const Color(0xFFF5E15F),
    ];

    ImageProvider? img;
    if (_imageFile != null) {
      img = FileImage(_imageFile!);
    } else if (_imagemUrlAtual != null) {
      img = NetworkImage(_imagemUrlAtual!);
    }

    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: gradientColors,
                  startAngle: 0,
                  endAngle: 3.14 * 2,
                ),
              ),
              child: CircleAvatar(
                radius: 52,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: const Color(0xFFE0E0E0),
                  backgroundImage: img,
                  child: img == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 81, 191, 255),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioDotted() {
    return SizedBox(
      height: 120,
      child: DottedBorder(
        options: RectDottedBorderOptions(
          dashPattern: const [3, 2],
          strokeWidth: 1,
          padding: const EdgeInsets.all(12),
          color: const Color.fromARGB(255, 160, 160, 160),
        ),
        child: TextFormField(
          controller: _bioController,
          maxLines: null,
          expands: true,
          decoration: const InputDecoration(
            hintText: 'Digite a biografia da instituição',
            hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxFormWidth = 500;
    final double horizontalPadding = screenWidth * 0.06;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Container(
          decoration: BoxDecoration(gradient: backgroundSla),
          padding: EdgeInsets.only(
            bottom: 75,
            left: horizontalPadding,
            right: horizontalPadding,
            top: 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxFormWidth),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: Colors.white,
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 6),
                              _buildProfileAvatar(),
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _nomeInstController,
                                decoration: _fieldDecoration('Digite o nome da instituição'),
                                validator: (v) => (v == null || v.trim().isEmpty)
                                    ? 'Informe o nome da instituição.'
                                    : null,
                              ),
                              const SizedBox(height: 10),

                              TextFormField(
                                controller: _campusController,
                                decoration: _fieldDecoration('Digite o campus/região da sua instituição'),
                              ),
                              const SizedBox(height: 10),

                              _buildBioDotted(),
                              const SizedBox(height: 10),

                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _fieldDecoration('Digite o email da instituição'),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) return 'Informe o email.';
                                  if (!v.contains('@')) return 'Email inválido.';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),

                              TextFormField(
                                controller: _senhaController,
                                obscureText: true,
                                decoration: _fieldDecoration('Nova senha (opcional)'),
                              ),
                              const SizedBox(height: 10),

                              TextFormField(
                                controller: _confirmarSenhaController,
                                obscureText: true,
                                decoration: _fieldDecoration('Confirmar nova senha (opcional)'),
                              ),
                              const SizedBox(height: 18),

                              SizedBox(
                                width: double.infinity,
                                height: 46,
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
                                  onPressed: _loading || _deleting ? null : _salvar,
                                  child: _loading
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Salvar alterações',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              SizedBox(
                                width: double.infinity,
                                height: 46,
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
                                  onPressed: _deleting || _instId == null ? null : _confirmarExcluir,
                                  child: _deleting
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Excluir instituição',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Botão de voltar (seta) no canto superior esquerdo
                      Positioned(
                        top: 8,
                        left: 8,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.pop(false),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
