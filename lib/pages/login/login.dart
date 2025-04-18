import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showWebView = false;
  late WebViewController webViewController;

  void setupWebView() {
    webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (NavigationRequest request) {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);

                // Check if the URL is our redirect URL
                if (request.url.startsWith(authProvider.redirectUrl)) {
                  final uri = Uri.parse(request.url);
                  final code = uri.queryParameters['code'];

                  if (code != null) {
                    // Exchange the code for an access token
                    authProvider.handleAuthCode(code).then((success) {
                      if (success) {
                        Navigator.of(context).pushReplacementNamed('/home');
                      } else {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Authentication failed')));
                        setState(() {
                          showWebView = false;
                        });
                      }
                    });
                    return NavigationDecision.prevent;
                  }
                }
                return NavigationDecision.navigate;
              },
              onPageFinished: (String url) {
                // Update loading state when page finishes loading
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                authProvider.isLoading = false;
                if (mounted) setState(() {});
              },
            ),
          );
  }

  void startLogin() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final loginUrl = authProvider.startAuthFlow();

    setState(() {
      showWebView = true;
    });

    webViewController.loadRequest(loginUrl);
  }

  @override
  void initState() {
    super.initState();
    setupWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Microsoft Login'),
        leading:
            showWebView
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      showWebView = false;
                      Provider.of<AuthProvider>(context, listen: false).isLoading = false;
                    });
                  },
                )
                : null,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return Center(
            child:
                showWebView
                    ? Stack(
                      children: [
                        WebViewWidget(controller: webViewController),
                        if (auth.isLoading) const Center(child: CircularProgressIndicator()),
                      ],
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (auth.isLoading)
                          const CircularProgressIndicator()
                        else
                          ElevatedButton(
                            onPressed: startLogin,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                            child: const Text('Sign in with Microsoft'),
                          ),
                      ],
                    ),
          );
        },
      ),
    );
  }
}
