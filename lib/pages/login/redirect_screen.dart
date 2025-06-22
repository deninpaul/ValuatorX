import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/providers/auth_provider.dart';

class RedirectScreen extends StatefulWidget {
  final String code;
  const RedirectScreen({super.key, required this.code});

  @override
  State<RedirectScreen> createState() => _RedirectScreenState();
}

class _RedirectScreenState extends State<RedirectScreen> {
  void _handleRedirect() async {
    final provider = Provider.of<AuthProvider>(context, listen: false);
    provider.handleAuthCode(widget.code).then((success) {
      if (success) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication failed')));
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => _handleRedirect());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
