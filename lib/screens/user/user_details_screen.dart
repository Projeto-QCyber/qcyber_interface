import 'package:flutter/material.dart';
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/objetos/user_summary.dart';
import 'package:zeropoint/services/user_service.dart';

class UserDetailsScreen extends StatefulWidget {
  final UserSummary user;
  const UserDetailsScreen({super.key, required this.user});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final UserService _userService = UserService();
  late bool _isAdmin;
  late bool _hasSystemAccess;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.user.isAdmin;
    _hasSystemAccess = widget.user.temPermissaoSistema;
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    final success = await _userService.updateUserPermissions(
      userId: widget.user.id,
      isAdmin: _isAdmin,
      hasSystemAccess: _hasSystemAccess,
    );
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Permissões atualizadas com sucesso!' : 'Falha ao atualizar.'),
        backgroundColor: success ? MyColors.success_qcyber : MyColors.error_qcyber,
      ));
      if (success) Navigator.pop(context, true);
    }
  }


  Future<void> _resetPassword() async {
    // Diálogo de confirmação para segurança
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Ação'),
        content: Text('Tem certeza que deseja redefinir a senha para ${widget.user.nome}? Uma senha temporária será enviada para o e-mail do usuário.'),
        actions: [
          TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.of(ctx).pop(false)),
          TextButton(child: const Text('Confirmar'), onPressed: () => Navigator.of(ctx).pop(true)),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final success = await _userService.resetPassword(widget.user.id);
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'E-mail com a nova senha enviado!' : 'Falha ao redefinir a senha.'),
        backgroundColor: success ? MyColors.success_qcyber : MyColors.error_qcyber,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background_qcyber,
      appBar: AppBar(
        title: Text(widget.user.nome),
        backgroundColor: MyColors.primary_qcyber,
        titleTextStyle: const TextStyle(color: MyColors.textOnPrimary_qcyber, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: MyColors.textOnPrimary_qcyber),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(Config.logoBranca, width: 100),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 24.0), // Padding inferior ajustado
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionCard(
                    title: 'Informações do Usuário',
                    children: [
                      _buildInfoRow('Nome Completo', widget.user.nome),
                      _buildInfoRow('Email', widget.user.email),
                      _buildInfoRow('Status', widget.user.ativo ? 'Ativo' : 'Inativo'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionCard(
                    title: 'Permissões de Acesso',
                    children: [
                      _buildPermissionSwitch(
                        title: 'Acesso ao Sistema',
                        subtitle: 'Permite que o usuário faça login no aplicativo.',
                        value: _hasSystemAccess,
                        onChanged: (value) => setState(() => _hasSystemAccess = value),
                      ),
                      const Divider(color: MyColors.border_qcyber),
                      _buildPermissionSwitch(
                        title: 'Administrador',
                        subtitle: 'Concede permissões para gerenciar usuários e parâmetros.',
                        value: _isAdmin,
                        onChanged: (value) => setState(() => _isAdmin = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Botão de salvar dentro da área de rolagem para melhor visibilidade
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar Alterações'),
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Rodapé padrão qCyber
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Image.asset(Config.logoAzul, height: 40, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES (sem alteração) ---

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      color: MyColors.card_qcyber,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: MyColors.border_qcyber),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: MyColors.textPrimary_qcyber)),
            const Divider(height: 24, color: MyColors.border_qcyber),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(color: MyColors.textSecondary_qcyber, fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: const TextStyle(color: MyColors.textPrimary_qcyber))),
        ],
      ),
    );
  }

  Widget _buildPermissionSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: MyColors.textPrimary_qcyber)),
      subtitle: Text(subtitle, style: const TextStyle(color: MyColors.textSecondary_qcyber)),
      value: value,
      onChanged: onChanged,
      activeColor: MyColors.success_qcyber,
      contentPadding: EdgeInsets.zero,
    );
  }
}