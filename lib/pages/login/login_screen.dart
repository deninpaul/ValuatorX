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
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication failed')));
                        setState(() => showWebView = false);
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
    setState(() => showWebView = true);
    webViewController.loadRequest(loginUrl);
  }

  onBackAction() {
    setState(() {
      showWebView = false;
      Provider.of<AuthProvider>(context, listen: false).isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    setupWebView();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final labelColor = colorScheme.onSurface.withAlpha(160);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainer,
        leading: showWebView ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBackAction) : null,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return Center(
            child:
                showWebView
                    ? Stack(
                      children: [
                        WebViewWidget(controller: webViewController),
                        if (auth.isLoading)
                          Container(color: colorScheme.surfaceContainer, alignment: Alignment.center, child: CircularProgressIndicator()),
                      ],
                    )
                    : (auth.isLoading
                        ? const CircularProgressIndicator()
                        : Container(
                          height: double.infinity,
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          color: colorScheme.surfaceContainer,
                          child: Column(
                            spacing: 24,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), color: colorScheme.surface),
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                                constraints: BoxConstraints(
                                  maxWidth: 424,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: colorScheme.surfaceContainer),
                                      child: Image.asset("assets/logo_mono.png", width: 48),
                                    ),
                                    SizedBox(height: 32),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: Column(
                                        spacing: 16,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Welcome to ValuatorX", style: textTheme.headlineMedium!.copyWith(height: 1.35)),
                                          Text(
                                            "ValuatorX makes it easy to create and manage valuation reports, with access to additional tools and resources",
                                            style: textTheme.bodyMedium!.copyWith(color: labelColor, height: 1.6),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 80),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 6),
                                      child: TextButton(
                                        onPressed: startLogin,
                                        style: TextButton.styleFrom(
                                          backgroundColor: colorScheme.primaryContainer,
                                          foregroundColor: colorScheme.onPrimaryContainer,
                                          padding: EdgeInsets.all(20),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                        child: Row(
                                          spacing: 16,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.window, size: 20),
                                            Text(
                                              "Sign in with Microsoft",
                                              style: textTheme.bodyMedium!.copyWith(color: colorScheme.onPrimaryContainer),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text("Made for Samanto Associates Pvt. Ltd.", style: textTheme.bodyMedium!.copyWith(color: labelColor)),
                            ],
                          ),
                        )),
          );
        },
      ),
    );
  }
}
