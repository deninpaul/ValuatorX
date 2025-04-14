import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/providers/auth_provider.dart';

class LogOut extends StatefulWidget {
  const LogOut({super.key});

  @override
  State<LogOut> createState() => _LogOutState();
}

class _LogOutState extends State<LogOut> {
  void signOut() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: signOut,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: const Text('Sign out'),
    );
  }
}
