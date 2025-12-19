import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://apec-1-25ad.onrender.com/api';
  static const Duration _timeout = Duration(seconds: 20);

  // ===== Storage keys =====
  static const String _kTokenKey = 'token';

  // ===== Helpers =====
  static Uri _uri(String path) => Uri.parse('$baseUrl$path');

  static Future<Map<String, String>> _jsonHeaders({bool auth = false}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await lerToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static Future<http.Response> _get(String path, {bool auth = false}) async {
    final headers = await _jsonHeaders(auth: auth);
    return http.get(_uri(path), headers: headers).timeout(_timeout);
  }

  static Future<http.Response> _post(String path,
      {required Object body, bool auth = false}) async {
    final headers = await _jsonHeaders(auth: auth);
    return http
        .post(_uri(path), headers: headers, body: json.encode(body))
        .timeout(_timeout);
  }

  static Future<http.Response> _put(String path,
      {required Object body, bool auth = false}) async {
    final headers = await _jsonHeaders(auth: auth);
    return http
        .put(_uri(path), headers: headers, body: json.encode(body))
        .timeout(_timeout);
  }

  static Future<http.Response> _delete(String path, {bool auth = false}) async {
    final headers = await _jsonHeaders(auth: auth);
    return http.delete(_uri(path), headers: headers).timeout(_timeout);
  }

  static Map<String, dynamic> _decodeMap(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    final decoded = json.decode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw Exception('Resposta não é um JSON objeto: $body');
  }

  static List<dynamic> _decodeList(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    final decoded = json.decode(body);
    if (decoded is List) return decoded;
    throw Exception('Resposta não é um JSON array: $body');
  }

  // ===== Sessão (token) =====
  static Future<void> salvarToken(String token) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kTokenKey, token);
  }

  static Future<String?> lerToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kTokenKey);
  }

  static Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kTokenKey);
  }

  static Future<bool> estaLogado() async {
    final token = await lerToken();
    return token != null && token.isNotEmpty;
  }

  // ===== Health =====
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

  // ============================================================
  // INSTITUIÇÃO
  // ============================================================

  /// Cadastro de instituição (imagem opcional)
  /// Endpoint esperado: POST /instituicoes
  static Future<Map<String, dynamic>> cadastrarInstituicaoSmart({
    required Map<String, dynamic> dados,
    File? imagem,
  }) async {
    final uri = _uri('/instituicoes');

    // Sem imagem -> JSON
    if (imagem == null) {
      final response = await http
          .post(
            uri,
            headers: await _jsonHeaders(auth: false),
            body: json.encode(dados),
          )
          .timeout(_timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return _decodeMap(response);
      }
      throw Exception(
        'Erro ao cadastrar instituição (JSON): ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
      );
    }

    // Com imagem -> Multipart
    final request = http.MultipartRequest('POST', uri);

    // Se o cadastro exigir auth, troque para auth: true e adicione Authorization aqui
    // request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // mesmo nome que você usa no evento
        imagem.path,
        filename: imagem.path.split('/').last,
      ),
    );

    dados.forEach((key, value) {
      if (value != null && key != 'imagem') {
        request.fields[key] = value.toString();
      }
    });

    final streamed = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return _decodeMap(response);
    }
    throw Exception(
      'Erro ao cadastrar instituição (Multipart): ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
    );
  }

  /// Login de instituição
  /// Endpoint esperado: POST /instituicoes/login
  /// Retorno esperado: { token: "...", ... }
  static Future<Map<String, dynamic>> loginInstituicao({
    required String email,
    required String senha,
  }) async {
    final response = await _post(
      '/instituicoes/login',
      body: {'email': email, 'senha': senha},
      auth: false,
    );

    if (response.statusCode == 200) {
      final data = _decodeMap(response);

      // Ajuste o campo se seu backend usar outro nome (ex: access_token)
      final token = data['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await salvarToken(token);
      }

      return data;
    }

    throw Exception(
      'Erro ao logar: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
    );
  }

  /// Perfil da instituição logada
  /// Endpoint esperado: GET /instituicoes/me  (auth Bearer)
  static Future<Map<String, dynamic>> minhaInstituicao() async {
    final response = await _get('/instituicoes/me', auth: true);

    if (response.statusCode == 200) {
      return _decodeMap(response);
    }

    throw Exception(
      'Erro ao buscar perfil: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
    );
  }

  // ============================================================
  // EVENTOS
  // ============================================================

  /// Listar todos os eventos
  static Future<List<dynamic>> listarEventos() async {
    final response = await _get('/eventos');

    if (response.statusCode == 200) {
      return _decodeList(response);
    }

    throw Exception(
      'Erro ao listar eventos: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
    );
  }

  /// Obter um evento por id
  static Future<Map<String, dynamic>> obterEvento(String id) async {
    final response = await _get('/eventos/$id');

    if (response.statusCode == 200) {
      return _decodeMap(response);
    }

    throw Exception(
      'Evento não encontrado: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
    );
  }

  /// Listar eventos por categoria
  static Future<List<dynamic>> listarEventosPorCategoria(String categoria) async {
    final response = await _get('/eventos/categoria/$categoria');

    if (response.statusCode == 200) {
      return _decodeList(response);
    }

    throw Exception(
      'Erro ao listar eventos por categoria: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
    );
  }

  /// Eventos da instituição logada
  /// Endpoint esperado: GET /eventos/me (auth Bearer)
  static Future<List<dynamic>> meusEventos() async {
    final response = await _get('/eventos/me', auth: true);

    if (response.statusCode == 200) {
      return _decodeList(response);
    }

    throw Exception(
      'Erro ao listar meus eventos: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
    );
  }

  /// Criar evento "smart" (imagem opcional)
  /// Endpoint esperado: POST /eventos
  static Future<Map<String, dynamic>> criarEventoSmart({
    required Map<String, dynamic> dados,
    File? imagem,
    bool auth = false, // coloque true se seu backend exigir token para criar evento
  }) async {
    final uri = _uri('/eventos');

    // Sem imagem -> JSON
    if (imagem == null) {
      final response = await http
          .post(
            uri,
            headers: await _jsonHeaders(auth: auth),
            body: json.encode(dados),
          )
          .timeout(_timeout);

      if (response.statusCode == 201) {
        return _decodeMap(response);
      }

      throw Exception(
        'Erro ao criar evento (JSON): ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
      );
    }

    // Com imagem -> Multipart
    final request = http.MultipartRequest('POST', uri);

    if (auth) {
      final token = await lerToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imagem.path,
        filename: imagem.path.split('/').last,
      ),
    );

    dados.forEach((key, value) {
      if (value != null && key != 'imagem') {
        request.fields[key] = value.toString();
      }
    });

    final streamed = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 201) {
      return _decodeMap(response);
    }

    throw Exception(
      'Erro ao criar evento (Multipart): ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
    );
  }

  /// Atualizar evento
  static Future<Map<String, dynamic>> atualizarEvento(
    String id,
    Map<String, dynamic> evento, {
    bool auth = false,
  }) async {
    final response = await _put('/eventos/$id', body: evento, auth: auth);

    if (response.statusCode == 200) {
      return _decodeMap(response);
    }

    throw Exception(
      'Erro ao atualizar evento: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
    );
  }

  /// Deletar evento
  static Future<void> deletarEvento(String id, {bool auth = false}) async {
    final response = await _delete('/eventos/$id', auth: auth);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    throw Exception(
      'Erro ao deletar evento: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
    );
  }
}
