// lib/screens/user_list_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // <--- IMPORTANTE: GoRouter
import 'package:zeropoint/_core/my_colors.dart';
import 'package:zeropoint/_core/config.dart';
import 'package:zeropoint/objetos/user_summary.dart';
import 'package:zeropoint/services/user_service.dart';
// Removemos a importação direta da UserDetailsScreen, pois o Router cuida disso

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();

  List<UserSummary>? _users;
  String? _error;
  bool _isLoading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchUsers({String searchTerm = ''}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _userService.getUsers(searchTerm: searchTerm);
      setState(() => _users = users);
    } catch (e) {
      setState(() => _error = 'Failed to load users. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchUsers(searchTerm: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
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
      backgroundColor: MyColors.background_qcyber,
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildContent()),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search by name or email...',
          prefixIcon: const Icon(Icons.search, color: MyColors.textSecondary_qcyber),
          filled: true,
          fillColor: MyColors.card_qcyber,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: MyColors.border_qcyber),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: MyColors.primary_qcyber, width: 2),
          ),
        ),
        style: const TextStyle(color: MyColors.textPrimary_qcyber),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: MyColors.error_qcyber)));
    }
    if (_users == null || _users!.isEmpty) {
      return const Center(child: Text('No users found.', style: TextStyle(color: MyColors.textPrimary_qcyber)));
    }
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 60.0),
          itemCount: _users!.length,
          itemBuilder: (context, index) {
            final user = _users![index];
            return Card(
              color: MyColors.card_qcyber,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: MyColors.border_qcyber)
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),

                // ATUALIZADO: Usando GoRouter e aguardando retorno
                onTap: () async {
                  // Navegamos para a rota de detalhes, passando o objeto 'user' no extra
                  // para não precisar buscar tudo de novo na próxima tela.
                  final bool? foiAtualizado = await context.push<bool>(
                      '/users/${user.id}',
                      extra: user
                  );

                  // Se a tela de detalhes retornar true (ex: usuário editado), atualizamos a lista
                  if (foiAtualizado == true) {
                    _fetchUsers();
                  }
                },

                child: ListTile(
                  leading: Icon(Icons.person, color: user.ativo ? MyColors.primary_qcyber : MyColors.textSecondary_qcyber),
                  title: Text(user.nome, style: const TextStyle(color: MyColors.textPrimary_qcyber)),
                  subtitle: Text(user.email, style: const TextStyle(color: MyColors.textSecondary_qcyber)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (user.isAdmin) Chip(label: const Text('Admin'), backgroundColor: MyColors.primary_qcyber.withOpacity(0.3)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: MyColors.textSecondary_qcyber),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 0, left: 0, right: 0, height: 50.0,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [MyColors.background_qcyber.withOpacity(0.0), MyColors.background_qcyber],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}