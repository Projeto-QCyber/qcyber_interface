// lib/models/user_summary.dart
class UserSummary {
  final int id;
  final String nome;
  final String email;
  final bool isAdmin;
  final bool temPermissaoSistema;
  final bool ativo;

  UserSummary({
    required this.id,
    required this.nome,
    required this.email,
    required this.isAdmin,
    required this.temPermissaoSistema,
    required this.ativo,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      isAdmin: json['is_admin'] ?? false,
      temPermissaoSistema: json['tem_permissao_sistema'] ?? false,
      ativo: json['ativo'] ?? false,
    );
  }
}