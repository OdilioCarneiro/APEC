import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:apec/pages/components/image_pick_crop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:apec/services/api_service.dart';
import 'package:go_router/go_router.dart'; // NECESSÁRIO pro context.pop()

final Gradient backgroundSla = const LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color.fromARGB(255, 248, 161, 168),
    Color.fromARGB(255, 163, 219, 252),
    Color.fromARGB(255, 255, 244, 171),
  ],
);

class CadasInstPage extends StatefulWidget {
  const CadasInstPage({super.key});

  @override
  State<CadasInstPage> createState() => _CadasInstPageState();
}

class _CadasInstPageState extends State<CadasInstPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeInstController = TextEditingController();
  final _campusController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  File? _imageFile;
  bool _loading = false;

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
  final file = await ImagePickCrop.pickAndCrop(
    context: context,
    source: ImageSource.gallery,
    cropStyle: CropStyle.circle,
    presets: const [CropAspectRatioPreset.square],
    lockedRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
  );

  if (file == null) return;
  setState(() => _imageFile = file);
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 81, 191, 255),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Future<void> _cadastrar() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    if (_senhaController.text != _confirmarSenhaController.text) {
      _snack('As senhas não coincidem.');
      return;
    }

    try {
      setState(() => _loading = true);
      _snack('Cadastrando...');

      final dados = <String, dynamic>{
        'nome': _nomeInstController.text.trim(),
        'campus': _campusController.text.trim(),
        'bio': _bioController.text.trim(),
        'email': _emailController.text.trim(),
        'senha': _senhaController.text,
      };

      await ApiService.cadastrarInstituicaoSmart(
        dados: dados,
        imagem: _imageFile,
      );

      if (!mounted) return;

      _snack('Cadastro realizado com sucesso!', bg: Colors.green);

      _nomeInstController.clear();
      _campusController.clear();
      _bioController.clear();
      _emailController.clear();
      _senhaController.clear();
      _confirmarSenhaController.clear();
      setState(() => _imageFile = null);

      // Se quiser fechar a tela após cadastrar:
      // context.pop();
    } catch (e) {
      _snack('Erro ao cadastrar: $e', bg: Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildProfileAvatar() {
    final gradientColors = <Color>[
      const Color(0xFFFA4050),
      const Color(0xFF59B0E3),
      const Color(0xFFF5E15F),
    ];

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
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
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

  Widget _buildActionButtons() {
    return Column(
      children: [
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
            onPressed: _loading ? null : _cadastrar,
            child: _loading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text(
                    'Cadastrar',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
            onPressed: () => context.pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxFormWidth = 500;
    final double horizontalPadding = screenWidth * 0.06;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false, // evita brigar com a TabView embaixo
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
                  child: SingleChildScrollView(
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
                            decoration: _fieldDecoration('Digite a senha'),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Informe a senha.';
                              if (v.length < 6) return 'Senha muito curta (mín. 6).';
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          TextFormField(
                            controller: _confirmarSenhaController,
                            obscureText: true,
                            decoration: _fieldDecoration('Confirmar senha'),
                            validator: (v) => (v == null || v.isEmpty) ? 'Confirme a senha.' : null,
                          ),
                          const SizedBox(height: 18),

                          _buildActionButtons(),
                        ],
                      ),
                    ),
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
