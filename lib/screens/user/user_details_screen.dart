// lib/screens/user/user_details_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <--- IMPORTANTE: GoRouter
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
        content: Text(success ? 'Permissions updated successfully!' : 'Failed to update.'),
        backgroundColor: success ? MyColors.success_qcyber : MyColors.error_qcyber,
      ));

      // ATUALIZADO: Usando GoRouter para voltar e retornar 'true'
      if (success) {
        context.pop(true);
      }
    }
  }

  Future<void> _resetPassword() async {
    // Diálogo de confirmação para segurança
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Action'),
        content: Text("Are you sure you want to reset the password for ${widget.user.nome}? A temporary password will be sent to the user's email."),
        actions: [
          // ATUALIZADO: Usando a extensão do GoRouter no contexto do diálogo (ctx)
          TextButton(child: const Text('Cancel'), onPressed: () => ctx.pop(false)),
          TextButton(child: const Text('Confirm'), onPressed: () => ctx.pop(true)),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    // Nota: O método resetPassword precisa estar implementado no UserService
    final success = await _userService.resetPassword(widget.user.id);
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Email with the new password has been sent!' : 'Failed to reset password.'),
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
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionCard(
                    title: 'User Information',
                    children: [
                      _buildInfoRow('Full Name', widget.user.nome),
                      _buildInfoRow('Email', widget.user.email),
                      _buildInfoRow('Status', widget.user.ativo ? 'Active' : 'Inactive'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionCard(
                    title: 'Access Permissions',
                    children: [
                      _buildPermissionSwitch(
                        title: 'System Access',
                        subtitle: 'Allows the user to log in to the application.',
                        value: _hasSystemAccess,
                        onChanged: (value) => setState(() => _hasSystemAccess = value),
                      ),
                      const Divider(color: MyColors.border_qcyber),
                      _buildPermissionSwitch(
                        title: 'Administrator',
                        subtitle: 'Grants permissions to manage users and parameters.',
                        value: _isAdmin,
                        onChanged: (value) => setState(() => _isAdmin = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Botão de Reset de Senha (Adicionado para usar a função _resetPassword)
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _resetPassword,
                    icon: const Icon(Icons.lock_reset, color: MyColors.warning_qcyber),
                    label: const Text("Reset User Password", style: TextStyle(color: MyColors.warning_qcyber)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: MyColors.warning_qcyber),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Save Changes'),
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),
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

  // --- WIDGETS AUXILIARES ---

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