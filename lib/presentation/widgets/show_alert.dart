import 'package:flutter/material.dart';

void showAlert(BuildContext context,String tittle, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tittle),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra la alerta
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }