import 'package:flutter/material.dart';
import 'package:frontend/services/user_image.dart';
import 'package:frontend/util/cookie.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    UserImage userImage = UserImage('admin');
    userImage.image(context).then((value) => print('Imagem do usuário carregada'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-vindo Uriel'),
        backgroundColor: theme.colorScheme.primary.withAlpha(200),
        foregroundColor: theme.colorScheme.onPrimary,
        leading: IconButton(
          onPressed: () {
            clearSession();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.logout),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Bem-vindo ao Sistema de Atendimentos!',
            ),
          ],
        ),
      ),
    );
  }
}
