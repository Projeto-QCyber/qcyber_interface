import 'package:flutter/material.dart';
import 'package:zeropoint/_core/constants.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/componentes/show_snackbar.dart';
import 'package:zeropoint/screens/MenuPage.dart';
import 'package:zeropoint/_core/Config.dart';
import 'package:zeropoint/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController(text: "usuario@email.com");
  final _senhaController = TextEditingController(text: "senha123");
  final _confirmaController = TextEditingController();
  final _nomeController = TextEditingController();

  bool isEntrando = true;
  final _formKey = GlobalKey<FormState>();

  final authService = AuthService();

  InputDecoration inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: MyColors.fundo_app1),
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: MyColors.fundo_app1)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: MyColors.fundo_app1)),
    errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
    focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 22),
                  child: Image.asset(
                    Config.logoAzul,
                    width: Config.logoWidthPrincipal,
                    height: Config.logoHeightPrincipal,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: MyColors.principal_app1,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            isEntrando ? "Bem vindo." : "Fazer o cadastro",
                            textAlign: TextAlign.center,
                            style: titulo_app1,
                          ),
                        ),
                        if (!isEntrando) ...[
                          TextFormField(
                            controller: _nomeController,
                            style: informacoesDeLogin_app1,
                            decoration: inputDecoration("Nome"),
                            validator: (value) =>
                            (value == null || value.length < 3) ? "Insira um nome maior." : null,
                          ),
                          const SizedBox(height: 8),
                        ],
                        TextFormField(
                          controller: _emailController,
                          style: informacoesDeLogin_app1,
                          decoration: inputDecoration("E-mail"),
                          validator: (value) => (value == null || value.isEmpty)
                              ? "O valor de e-mail deve ser preenchido"
                              : (!value.contains("@") || !value.contains("."))
                              ? "O valor do e-mail deve ser válido"
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _senhaController,
                          obscureText: true,
                          style: informacoesDeLogin_app1,
                          decoration: inputDecoration("Senha"),
                          validator: (value) =>
                          (value == null || value.length < 4) ? "Insira uma senha válida." : null,
                        ),
                        if (!isEntrando) ...[
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _confirmaController,
                            obscureText: true,
                            style: informacoesDeLogin_app1,
                            decoration: inputDecoration("Confirme a senha"),
                            validator: (value) => value != _senhaController.text ? "As senhas devem ser iguais." : null,
                          ),
                        ],
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: MyColors.fundo_app1),
                          onPressed: botaoEnviarClicado,
                          child: Text(isEntrando ? "Entrar" : "Cadastrar", style: btnLogin_app1),
                        ),
                        TextButton(
                          onPressed: () => setState(() => isEntrando = !isEntrando),
                          child: Text(
                            isEntrando
                                ? "Ainda não tem conta?\nClique aqui para cadastrar."
                                : "Já tem uma conta?\nClique aqui para entrar",
                            textAlign: TextAlign.center,
                            style: informacoesDeLogin_app1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void botaoEnviarClicado() {
    if (_formKey.currentState!.validate()) {
      isEntrando ? _entrarUsuario() : _criarUsuario();
    }
  }

  void _entrarUsuario() async {
    final login = await authService.entrarUsuario(
        context: context, email: _emailController.text, senha: _senhaController.text);
    if (login == "s") Navigator.push(context, MaterialPageRoute(builder: (_) => MenuPage()));
    else showSnackBar(context: context, mensagem: login ?? "Erro ao entrar.");
  }

  void _criarUsuario() async {
    print("object");
    // final cadastro = await authService.cadastrarUsuario(
    //     context: context,
    //     email: _emailController.text,
    //     senha: _senhaController.text,
    //     nome: _nomeController.text);
    // if (cadastro == "s") setState(() => isEntrando = true);
    // showSnackBar(context: context, mensagem: cadastro ?? "Erro ao cadastrar.");
  }
}
