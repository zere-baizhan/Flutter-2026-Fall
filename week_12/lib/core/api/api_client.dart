import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../storage/secure_store.dart';
import 'api_exception.dart';

export 'package:http/http.dart' show Client;

class ApiClient {
  ApiClient(
    this._client,
    this._store, {
    this.host = 'jsonplaceholder.typicode.com',
  });

  final http.Client _client;
  final SecureStore _store;
  final String host;

  static const _timeout = Duration(seconds: 10);

  
  Future<Map<String, String>> _headers() async => {
    'Accept': 'application/json',
    if (await _store.readToken() case final t?) 'Authorization': 'Bearer $t',
  };

  Future<http.Response> get(Uri uri) async {
    final headers = await _headers();
    final r = await _send(() => _client.get(uri, headers: headers));
    _check(r);
    return r;
  }

  Future<http.Response> post(Uri uri, Map<String, dynamic> body) async {
    final headers = await _headers();
    final r = await _send(
      () => _client.post(
        uri,
        headers: {...headers, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
    _check(r);
    return r;
  }

  dynamic decode(http.Response r) => _decode(r);

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final r = await call().timeout(_timeout);
      if (kDebugMode) {
        log(
          '${r.request?.method} ${r.request?.url} → ${r.statusCode} '
          '(${r.bodyBytes.length} bytes)',
          name: 'api',
        );
      }
      return r;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    }
  }

  void _check(http.Response r) {
    final s = r.statusCode;
    if (s == 401) throw const UnauthorizedException();
    if (s == 404) throw const NotFoundException();
    if (s >= 500) throw ServerException(s);
    if (s < 200 || s >= 300) throw BadResponseException('HTTP $s');
  }

  dynamic _decode(http.Response r) {
    try {
      return jsonDecode(r.body);
    } on FormatException catch (e) {
      throw BadResponseException('not JSON: ${e.message}');
    }
  }
}
