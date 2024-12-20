import 'package:flutter/material.dart';
import 'package:frontend/pages/startup.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'util/global.dart';

void main() {
  initializeDateFormatting('pt_BR', null).then((_) => runApp(const SAAmendola()));
}

class SAAmendola extends StatelessWidget {
  const SAAmendola({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Global.context = context;

    return MaterialApp(
      title: 'Sistema de Atêndimento - Amêndola & Amêndola',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 191, 0)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const StartupScreen(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
    );
  }
}
