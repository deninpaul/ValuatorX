import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Microsoft Auth Demo',
      theme: ThemeData(primarySwatch: Colors.blue, visualDensity: VisualDensity.adaptivePlatformDensity),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  String? _accessToken;
  bool _isLoading = false;
  bool _showWebView = false;

  // Microsoft OAuth configuration
  final String clientId = '157012b8-d0a6-45ec-a9fc-3c7a9c107f27';
  final String tenantId = 'common';
  final String redirectUrl = 'https://login.microsoftonline.com/common/oauth2/nativeclient';
  final List<String> scopes = ['openid', 'profile', 'email', 'User.Read'];

  // OAuth endpoints
  late final Uri authorizationEndpoint;
  late final Uri tokenEndpoint;

  // Grant object
  oauth2.AuthorizationCodeGrant? _grant;

  // WebView controller
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    // Initialize OAuth endpoints
    authorizationEndpoint = Uri.parse('https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize');
    tokenEndpoint = Uri.parse('https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token');

    _initWebViewController();
  }

  void _initWebViewController() {
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (NavigationRequest request) {
                // Check if the URL is our redirect URL
                if (request.url.startsWith(redirectUrl)) {
                  // Extract the authorization code from the URL
                  final uri = Uri.parse(request.url);
                  final code = uri.queryParameters['code'];

                  if (code != null && _grant != null) {
                    // Exchange the code for an access token
                    _getAccessToken(code);

                    // Close the WebView
                    setState(() {
                      _showWebView = false;
                    });

                    // Prevent the WebView from navigating to the redirect URL
                    return NavigationDecision.prevent;
                  }
                }
                // Allow all other navigations
                return NavigationDecision.navigate;
              },
              onPageFinished: (String url) {
                setState(() {
                  _isLoading = false;
                });
              },
            ),
          );
  }

  void _startAuthFlow() {
    setState(() {
      _isLoading = true;
      _showWebView = true;
      _accessToken = null;
    });

    // Create the OAuth2 grant
    _grant = oauth2.AuthorizationCodeGrant(clientId, authorizationEndpoint, tokenEndpoint, secret: "atp8Q~3CqLWp5KdBZKFBhhMcaGslqGvljIwEmbo4");

    // Generate the authorization URL
    final authUrl = _grant!.getAuthorizationUrl(Uri.parse(redirectUrl), scopes: scopes);

    // Load the authorization URL in the WebView
    _webViewController.loadRequest(authUrl);
  }

  Future<void> _getAccessToken(String code) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Exchange the authorization code for credentials
      final client = await _grant!.handleAuthorizationCode(code);

      setState(() {
        _accessToken = client.credentials.accessToken;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Authentication failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Microsoft Login'),
        // Add a back button when WebView is showing
        leading:
            _showWebView
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _showWebView = false;
                      _isLoading = false;
                    });
                  },
                )
                : null,
      ),
      body: Center(
        child:
            _showWebView
                ? Stack(
                  children: [
                    WebViewWidget(controller: _webViewController),
                    if (_isLoading) const Center(child: CircularProgressIndicator()),
                  ],
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: _startAuthFlow,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Sign in with Microsoft'),
                      ),
                    const SizedBox(height: 30),
                    if (_accessToken != null) ...[
                      const Text(
                        'Successfully signed in!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Access Token:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            Container(
                              height: 100,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: SingleChildScrollView(
                                child: Text(_accessToken!, style: const TextStyle(fontFamily: 'monospace')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
      ),
    );
  }
}
