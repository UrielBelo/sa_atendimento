import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:frontend/components/alert.dart';
import 'package:frontend/util/aes.dart';
import 'package:frontend/util/cookie.dart';
import 'package:frontend/util/hash.dart';
import 'package:frontend/util/http.dart';
import 'package:frontend/util/global.dart';
import 'package:frontend/util/pow.dart';
import 'package:frontend/util/sha256.dart';

class SecureRequest {
  BuildContext context;
  HTTPUtil http = HTTPUtil();

  SecureRequest({required this.context});

  Future<Map<String, dynamic>?> post(String route, [Map<String, dynamic>? data, bool? getMethod]) async {
    final String userHash = sha256(Global.session!.username);
    final String scrambler = randomHash(32);
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String sessionHash = Global.session!.sessionHash;
    String authorization = '$sessionHash:$timestamp:$scrambler';

    String challengeProof = solveHashcash(Global.session!.signToken, 2);

    authorization = aesEncrypt(authorization, Global.aesKey!, Global.aesIv!);
    timestamp = aesEncrypt(timestamp, Global.aesKey!, Global.aesIv!);
    challengeProof = aesEncrypt(challengeProof, Global.aesKey!, Global.aesIv!);

    Map<String, String> headers = {
      'x-user-hash': userHash,
      'x-authorization': authorization,
      'x-scrambler': scrambler,
      'x-client-timestamp': timestamp,
      'x-request-token': challengeProof,
    };

    Response response = getMethod != null ? await http.get('${Global.url}$route', headers) : await http.post('${Global.url}$route', data, headers);

    Map<String, dynamic> requestBody = jsonDecode(response.body);
    if (requestBody.containsKey('error') && context.mounted) {
      showAlertWithText(context, Icons.error_outline, requestBody['error']);
      return null;
    }

    Map<String, String> responseHeaders = response.headers;
    Global.session!.signToken = responseHeaders['x-sign-token'] != null ? aesDecrypt(responseHeaders['x-sign-token']!, Global.aesKey!, Global.aesIv!) : Global.session!.signToken;

    renewSession(Global.aesKey!, Global.aesIv!, Global.session!);

    try {
      Map<String, dynamic> body = jsonDecode(response.body);
      return body;
    } catch (error) {
      if (context.mounted) {
        showAlertWithText(context, Icons.error_outline, 'Erro ao decodificar o corpo da resposta');
      }
      return null;
    }
  }
}
