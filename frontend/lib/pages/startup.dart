import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/pages/homepage.dart';
import 'package:frontend/pages/login.dart';
import 'package:frontend/util/global.dart';
import '../util/cookie.dart';

class StartupScreenState extends ChangeNotifier {
  BuildContext context;

  StartupScreenState({
    required this.context,
  });

  void initApp() async {
    Map<String, dynamic>? cookies = loadSession();
    if (cookies == null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));

    Global.aesIv = cookies['aesIv'];
    Global.aesKey = cookies['aesKey'];
    Global.session = cookies['session'];

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Homepage()));
    return;
  }
}

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StartupScreenState(context: context),
      child: Builder(builder: (context) {
        StartupScreenState startupScreenState = StartupScreenState(context: context);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          startupScreenState.initApp();
        });
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }),
    );
  }
}
