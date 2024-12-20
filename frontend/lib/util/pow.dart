import 'package:frontend/util/sha256.dart';

String solveHashcash(String input, int difficulty) {
  int nonce = 0; // Inicializa o nonce
  String prefix = '0' * difficulty; // Prefixo desejado (ex: '00')

  while (true) {
    // Concatena o input e o nonce
    String data = '$input$nonce';

    // Calcula o hash SHA256
    String hash = sha256(data);
    String hashString = hash.toString();

    // Verifica se o hash começa com o prefixo desejado
    if (hashString.startsWith(prefix)) {
      return nonce.toString(); // Retorna o hash válido encontrado
    }

    nonce++; // Incrementa o nonce para tentar outro valor
  }
}
