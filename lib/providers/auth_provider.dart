import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:path_provider/path_provider.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  oauth2.Credentials? _credentials;

  // Microsoft OAuth configuration
  final String _clientId = dotenv.env['CLIENT_ID']!;
  final String _tenantId = dotenv.env['TENANT_ID']!;
  final List<String> _scopes = ['openid', 'profile', 'email', 'offline_access', 'User.Read', 'Files.ReadWrite'];

  late final Uri _authorizationEndpoint;
  late final Uri _tokenEndpoint;
  late final String redirectUrl;
  late File _credentialsFile;

  AuthProvider() {
    _authorizationEndpoint = Uri.parse('https://login.microsoftonline.com/$_tenantId/oauth2/v2.0/authorize');
    _tokenEndpoint = Uri.parse('https://login.microsoftonline.com/$_tenantId/oauth2/v2.0/token');
    redirectUrl = "https://login.microsoftonline.com/$_tenantId/oauth2/nativeclient";
  }

  // OAuth grant object
  oauth2.AuthorizationCodeGrant? _grant;

  // Check if user is authenticated
  Future<bool> get isAuthenticated async {
    if (_credentials == null) {
      await _getCredentials();
    }
    return _credentials != null;
  }

  // Get OAuth client
  Future<oauth2.Client> getClient() async {
    if (_credentials == null) {
      await _getCredentials();
    }
    return oauth2.Client(
      _credentials!,
      identifier: _clientId,
      onCredentialsRefreshed: (updated) => _saveCredentials(updated),
    );
  }

  // Start authentication flow
  Uri startAuthFlow() {
    setLoading(true);
    _grant = oauth2.AuthorizationCodeGrant(_clientId, _authorizationEndpoint, _tokenEndpoint);
    return _grant!.getAuthorizationUrl(Uri.parse(redirectUrl), scopes: _scopes);
  }

  // Handle authorization code after login
  Future<bool> handleAuthCode(String code) async {
    setLoading(true);
    try {
      final client = await _grant!.handleAuthorizationCode(code);
      _saveCredentials(client.credentials);
      setLoading(false);
      return true;
    } catch (e) {
      setLoading(false);
      debugPrint("Error handling auth code: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    _credentials = null;
    await _credentialsFile.delete();
    notifyListeners();
  }

  Future<void> _getCredentials() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _credentialsFile = File('${dir.path}/credentials.json');

      final json = await _credentialsFile.readAsString();
      _credentials = oauth2.Credentials.fromJson(json);
      notifyListeners();
    } catch (e) {
      debugPrint("Error getting credentials: $e");
    }
  }

  Future<void> _saveCredentials(oauth2.Credentials newCredentials) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _credentialsFile = File('${dir.path}/credentials.json');

      _credentials = newCredentials;
      await _credentialsFile.writeAsString(_credentials!.toJson());
      notifyListeners();
    } catch (e) {
      debugPrint("Error saving credentials: $e");
    }
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
