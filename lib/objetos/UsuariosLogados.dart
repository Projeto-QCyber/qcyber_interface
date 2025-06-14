

import 'package:flutter/material.dart';

class UsuariosLogados extends ChangeNotifier{


  int id;
  String nome;


  UsuariosLogados({
    required this.id,
    required this.nome,
  });


  void atualizar(){
    notifyListeners();
  }

  void atualizarUsuarioLogado(int idr, String nomer) {
    id = idr;
    nome = nomer;
    notifyListeners();
  }

}