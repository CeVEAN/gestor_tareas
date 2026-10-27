import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final email = authService.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis tableros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: Center(
        child: Text('Sesión iniciada como:\n$email', textAlign: TextAlign.center),
      ),
    );
  }
}