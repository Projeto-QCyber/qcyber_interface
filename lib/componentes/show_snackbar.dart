import 'package:flutter/material.dart';


showSnackBar({required BuildContext context, required String mensagem, bool isErro = true}) {
  SnackBar snackBar = SnackBar(content: Text(mensagem), backgroundColor: (isErro)? Colors.red : Colors.blue,);

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}