import 'package:flutter/material.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  String? accessToken;
  bool isLoading = false;
  bool get isAuthenticated => accessToken != null;

  // Microsoft OAuth configuration
  final String clientId = '157012b8-d0a6-45ec-a9fc-3c7a9c107f27';
  final String clientSecret = "atp8Q~3CqLWp5KdBZKFBhhMcaGslqGvljIwEmbo4";
  final String tenantId = 'common';
  final String redirectUrl = 'https://login.microsoftonline.com/common/oauth2/nativeclient';
  final List<String> scopes = ['openid', 'profile', 'email', 'User.Read'];
  late final Uri authorizationEndpoint;
  late final Uri tokenEndpoint;

  // Grant object
  oauth2.AuthorizationCodeGrant? _grant;
  
  // SharedPreferences instance for storage
  final SharedPreferences prefs;

  AuthProvider(this.prefs) {
    authorizationEndpoint = Uri.parse('https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize');
    tokenEndpoint = Uri.parse('https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token');
    accessToken = prefs.getString('accessToken');
  }

  // Create the OAuth grant and return the authorization URL
  Uri startAuthFlow() {
    isLoading = true;
    notifyListeners();

    // Create the OAuth2 grant
    _grant = oauth2.AuthorizationCodeGrant(
      clientId,
      authorizationEndpoint,
      tokenEndpoint,
      secret: clientSecret,
    );

    // Generate the authorization URL
    final authUrl = _grant!.getAuthorizationUrl(
      Uri.parse(redirectUrl),
      scopes: scopes,
    );

    return authUrl;
  }

  Future<bool> handleAuthCode(String code) async {
    isLoading = true;
    notifyListeners();

    try {
      // Exchange the authorization code for credentials
      final client = await _grant!.handleAuthorizationCode(code);
      accessToken = client.credentials.accessToken;
      
      // Save the access token to shared preferences
      await prefs.setString('accessToken', accessToken!);
      
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    accessToken = null;
    await prefs.remove('accessToken');
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}