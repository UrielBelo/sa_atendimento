import 'package:frontend/classes/session.dart';
import 'package:universal_html/html.dart';

void saveSession(String aesKey, String aesIv, Session session) {
  // Cria os cookies
  document.cookie = 'aesKey=$aesKey; max-age=3600; path=/; secure; samesite=strict;';
  document.cookie = 'aesIv=$aesIv; max-age=3600; path=/; secure; samesite=strict;';
  document.cookie = 'session=${Uri.encodeComponent(session.toJson())}; max-age=3600; path=/; secure; samesite=strict;';
}

void saveLastPage(String lastPage) {
  document.cookie = 'lastPage=$lastPage; max-age=3600; path=/; secure; samesite=strict;';
}

void renewSession(String aesKey, String aesIv, Session session) {
  saveSession(aesKey, aesIv, session); // Reescreve os cookies com 1 hora
}

void clearSession() {
  document.cookie = 'aesKey=; max-age=0; path=/;';
  document.cookie = 'aesIv=; max-age=0; path=/;';
  document.cookie = 'session=; max-age=0; path=/;';
  document.cookie = 'lastPage=; max-age=0; path=/;';
  document.cookie = 'signToken=; max-age=0; path=/;';
}

Map<String, String> getCookies() {
  final cookies = document.cookie?.split('; ') ?? [];
  final cookieMap = <String, String>{};

  for (final cookie in cookies) {
    final split = cookie.split('=');
    if (split.length == 2) {
      cookieMap[split[0]] = split[1];
    }
  }

  return cookieMap;
}

Map<String, dynamic>? loadSession() {
  final cookies = getCookies();
  final aesKey = cookies['aesKey'];
  final aesIv = cookies['aesIv'];
  final sessionString = cookies['session'];
  final lastPage = cookies['lastPage'];
  final signToken = cookies['signToken'];

  if (aesKey != null && aesIv != null && sessionString != null) {
    final session = Uri.decodeComponent(sessionString);
    Session parsedSession = Session.fromJson(session);

    return {'aesKey': aesKey, 'aesIv': aesIv, 'session': parsedSession, 'lastPage': lastPage, 'signToken': signToken};
  }

  return null; // Não há sessão válida
}
