import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String message;
  final String content;
  final String confirmText;
  final VoidCallback onConfirm;

  const CustomAlertDialog({
    required this.message,
    required this.content,
    required this.confirmText,
    required this.onConfirm,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(message),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: onConfirm,
          child: Text(confirmText),
        ),
        TextButton(
          child: const Text('キャンセル'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return this;
      },
    );
  }
}
