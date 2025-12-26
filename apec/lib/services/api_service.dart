// services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://apec-1-25ad.onrender.com/api';
  static const Duration _timeout = Duration(seconds: 20);

  // Storage keys
  static const String _kInstituicaoIdKey = 'instituicaoId';

  // Helpers
  static Uri _uri(String path) => Uri.parse('$baseUrl$path');

  static String _bodyUtf8(http.Response response) => utf8.decode(response.bodyBytes);

  static Map<String, dynamic> _decodeMap(http.Response response) {
    final body = _bodyUtf8(response);
    final decoded = json.decode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception('Resposta não é um JSON objeto: $body');
  }

  static List<dynamic> _decodeList(http.Response response) {
    final body = _bodyUtf8(response);
    final decoded = json.decode(body);
    if (decoded is List) return decoded;
    throw Exception('Resposta não é um JSON array: $body');
  }

  static Map<String, String> _headersJson() => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Never _throwHttp(http.Response response, String prefix) {
    throw Exception('$prefix: ${response.statusCode} - ${_bodyUtf8(response)}');
  }

  // Sessão
  static Future<void> salvarInstituicaoId(String id) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kInstituicaoIdKey, id);
  }

  static Future<String?> lerInstituicaoId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kInstituicaoIdKey);
  }

  static Future<void> logoutInstituicao() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kInstituicaoIdKey);
  }

  static Future<bool> instituicaoLogada() async {
    final id = await lerInstituicaoId();
    return id != null && id.isNotEmpty;
  }

  // Health
  static Future<bool> verificarSaude() async {
    try {
      final response = await http
          .get(Uri.parse('${baseUrl.replaceAll('/api', '')}/api/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // INSTITUIÇÃO

  static Future<Map<String, dynamic>> cadastrarInstituicaoSmart({
    required Map<String, dynamic> dados,
    File? imagem,
  }) async {
    final request = http.MultipartRequest('POST', _uri('/instituicoes'));

    dados.forEach((key, value) {
      if (value != null) request.fields[key] = value.toString();
    });

    if (imagem != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imagem.path,
          filename: imagem.path.split('/').last,
        ),
      );
    }

    final streamed = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return _decodeMap(response);
    }

    _throwHttp(response, 'Erro ao cadastrar instituição');
  }

  static Future<Map<String, dynamic>> atualizarInstituicaoSmart({
  required String instituicaoId,
  required Map<String, dynamic> dados,
  File? novaImagem,
}) async {
  final uri = _uri('/instituicoes/$instituicaoId');

  // Se NÃO tem imagem nova, manda JSON normal (mais simples)
  if (novaImagem == null) {
    final response = await http
        .put(
          uri,
          headers: _headersJson(),
          body: json.encode(dados),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeMap(response);
    }

    _throwHttp(response, 'Erro ao atualizar instituição (JSON)');
  }

  // Se TEM imagem nova, manda multipart
  final request = http.MultipartRequest('PUT', uri);

  dados.forEach((key, value) {
    if (value != null) request.fields[key] = value.toString();
  });

  request.files.add(
    await http.MultipartFile.fromPath(
      'file', // MESMO campo do cadastro
      novaImagem.path,
      filename: novaImagem.path.split('/').last,
    ),
  );

  final streamed = await request.send().timeout(_timeout);
  final response = await http.Response.fromStream(streamed);

  if (response.statusCode == 200) {
    return _decodeMap(response);
  }

  _throwHttp(response, 'Erro ao atualizar instituição (Multipart)');
}


  static Future<Map<String, dynamic>> loginInstituicao({
    required String email,
    required String senha,
  }) async {
    final response = await http
        .post(
          _uri('/instituicoes/login'),
          headers: _headersJson(),
          body: json.encode({'email': email, 'senha': senha}),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = _decodeMap(response);

      final id = data['instituicaoId']?.toString();
      if (id == null || id.isEmpty) {
        throw Exception('Login OK, mas resposta sem instituicaoId: ${_bodyUtf8(response)}');
      }

      await salvarInstituicaoId(id);
      return data;
    }

    _throwHttp(response, 'Erro ao logar');
  }

  static Future<void> deletarInstituicao(String id) async {
  final response = await http
      .delete(_uri('/instituicoes/$id'))
      .timeout(_timeout);

  if (response.statusCode == 200 || response.statusCode == 204) return;
  _throwHttp(response, 'Erro ao deletar instituição');
}


  static Future<Map<String, dynamic>> obterInstituicaoPorId(String id) async {
    final response = await http.get(_uri('/instituicoes/$id')).timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeMap(response);
    }

    _throwHttp(response, 'Erro ao obter instituição');
  }

  static Future<Map<String, dynamic>> minhaInstituicao() async {
    final id = await lerInstituicaoId();
    if (id == null || id.isEmpty) {
      throw Exception('Sem instituicaoId (não logado).');
    }
    return obterInstituicaoPorId(id);
  }

  static Future<List<dynamic>> listarInstituicoes() async {
    final response = await http.get(_uri('/instituicoes')).timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeList(response);
    }

    _throwHttp(response, 'Erro ao listar instituições');
  }


  // EVENTOS

  static Future<List<dynamic>> listarEventos() async {
    final response = await http.get(_uri('/eventos')).timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeList(response);
    }

    _throwHttp(response, 'Erro ao listar eventos');
  }

  static Future<Map<String, dynamic>> obterEvento(String id) async {
    final response = await http.get(_uri('/eventos/$id')).timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeMap(response);
    }

    _throwHttp(response, 'Erro ao obter evento');
  }

  static Future<List<dynamic>> listarEventosPorCategoria(String categoria) async {
    final response =
        await http.get(_uri('/eventos/categoria/$categoria')).timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeList(response);
    }

    _throwHttp(response, 'Erro ao listar eventos por categoria');
  }

  static Future<List<dynamic>> meusEventos() async {
    final instituicaoId = await lerInstituicaoId();
    if (instituicaoId == null || instituicaoId.isEmpty) {
      throw Exception('Sem instituicaoId (não logado).');
    }

    final response =
        await http.get(_uri('/eventos/instituicao/$instituicaoId')).timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeList(response);
    }

    _throwHttp(response, 'Erro ao listar eventos da instituição');
  }

  static Future<Map<String, dynamic>> criarEventoSmart({
    required Map<String, dynamic> dados,
    File? imagem,
  }) async {
    final uri = _uri('/eventos');

    if (imagem == null) {
      final response = await http
          .post(
            uri,
            headers: _headersJson(),
            body: json.encode(dados),
          )
          .timeout(_timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return _decodeMap(response);
      }

      _throwHttp(response, 'Erro ao criar evento (JSON)');
    }

    final request = http.MultipartRequest('POST', uri);

    dados.forEach((key, value) {
      if (value == null) return;
      if (key == 'imagem') return;
      request.fields[key] = value.toString();
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imagem.path,
        filename: imagem.path.split('/').last,
      ),
    );

    final streamed = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return _decodeMap(response);
    }

    _throwHttp(response, 'Erro ao criar evento (Multipart)');
  }

  static Future<Map<String, dynamic>> atualizarEvento(
    String id,
    Map<String, dynamic> evento,
  ) async {
    final response = await http
        .put(
          _uri('/eventos/$id'),
          headers: _headersJson(),
          body: json.encode(evento),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeMap(response);
    }

    _throwHttp(response, 'Erro ao atualizar evento');
  }

  static Future<Map<String, dynamic>> atualizarCategoriasSubeventos({
    required String eventoId,
    required List<String> categoriasTitulos,
  }) async {
    final response = await http
        .put(
          _uri('/eventos/$eventoId'),
          headers: _headersJson(),
          body: json.encode({'categoriasSubeventos': categoriasTitulos}),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) return _decodeMap(response);
    _throwHttp(response, 'Erro ao atualizar categoriasSubeventos');
  }

  static Future<void> deletarEvento(String id) async {
    final response = await http
        .delete(
          _uri('/eventos/$id'),
          headers: _headersJson(),
        )
        .timeout(_timeout);

    if (response.statusCode == 200 || response.statusCode == 204) return;

    _throwHttp(response, 'Erro ao deletar evento');
  }

  // SUBEVENTOS

  static Future<List<dynamic>> listarSubEventos({String? eventoPaiId}) async {
    final base = _uri('/subeventos');

    final uri = (eventoPaiId == null || eventoPaiId.isEmpty)
        ? base
        : base.replace(queryParameters: {'eventoPaiId': eventoPaiId});

    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeList(response);
    }

    _throwHttp(response, 'Erro ao listar subeventos');
  }

  static Future<Map<String, dynamic>> obterSubEvento(String id) async {
    final response = await http.get(_uri('/subeventos/$id')).timeout(_timeout);

    if (response.statusCode == 200) {
      return _decodeMap(response);
    }

    _throwHttp(response, 'Erro ao obter subevento');
  }

  static Future<Map<String, dynamic>> criarSubEventoSmart({
    required Map<String, dynamic> dados,
    File? imagem,
  }) async {
    final uri = _uri('/subeventos');

    if (imagem == null) {
      final response = await http
          .post(
            uri,
            headers: _headersJson(),
            body: json.encode(dados),
          )
          .timeout(_timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return _decodeMap(response);
      }

      _throwHttp(response, 'Erro ao criar subevento (JSON)');
    }

    final request = http.MultipartRequest('POST', uri);

    dados.forEach((key, value) {
      if (value == null) return;
      if (key == 'imagem') return;
      request.fields[key] = value.toString();
    });

    request.files.add(
      await http.MultipartFile.fromPath(
        'imagem',
        imagem.path,
        filename: imagem.path.split('/').last,
      ),
    );

    final streamed = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return _decodeMap(response);
    }

    _throwHttp(response, 'Erro ao criar subevento (Multipart)');
  }

 static Future<Map<String, dynamic>> atualizarSubEventoSmart({
      required String id,
      required Map<String, dynamic> dados,
      File? novaImagem,
    }) async {
      final uri = _uri('/subeventos/$id');

      // Se NÃO tem imagem nova, manda JSON normal (igual seu atualizarSubEvento atual)
      if (novaImagem == null) {
        final response = await http
            .put(
              uri,
              headers: _headersJson(),
              body: json.encode(dados),
            )
            .timeout(_timeout);

        if (response.statusCode == 200) {
          return _decodeMap(response);
        }

        _throwHttp(response, 'Erro ao atualizar subevento (JSON)');
      }

      // Se TEM imagem nova, manda multipart (igual criarSubEventoSmart)
      final request = http.MultipartRequest('PUT', uri);

      dados.forEach((key, value) {
        if (value == null) return;
        if (key == 'imagem') return; // evita duplicar caso alguém mande no map
        request.fields[key] = value.toString();
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'imagem', // MESMO campo do criarSubEventoSmart
          novaImagem.path,
          filename: novaImagem.path.split('/').last,
        ),
      );

      final streamed = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        return _decodeMap(response);
      }

      _throwHttp(response, 'Erro ao atualizar subevento (Multipart)');
    }


  static Future<void> deletarSubEvento(String id) async {
    final response = await http.delete(_uri('/subeventos/$id')).timeout(_timeout);

    if (response.statusCode == 200 || response.statusCode == 204) return;

    _throwHttp(response, 'Erro ao deletar subevento');
  }

  static Future<Map<String, dynamic>> renomearCategoriaSubeventos({
    required String eventoId,
    required String antiga,
    required String nova,
  }) async {
    final response = await http
        .put(
          _uri('/eventos/$eventoId/renomear-categoria'),
          headers: _headersJson(),
          body: json.encode({'antiga': antiga, 'nova': nova}),
        )
        .timeout(_timeout);

    if (response.statusCode == 200) return _decodeMap(response);
    _throwHttp(response, 'Erro ao renomear categoria');
  }
}
