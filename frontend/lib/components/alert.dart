import 'package:flutter/material.dart';

showAlertWithText(BuildContext context, IconData icon, String text) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        scrollable: true,
        title: Icon(icon),
        content: SizedBox(
          width: 500,
          child: Text(text),
        ),
        actions: [
          TextButton(
            child: const Text('Fechar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
