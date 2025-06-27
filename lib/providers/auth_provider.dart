import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:valuatorx/services/settings_service.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  oauth2.Credentials? _credentials;
  oauth2.AuthorizationCodeGrant? _grant;
  bool _hasHandledCode = false;

  // Microsoft OAuth configuration
  final String _clientId = kIsWeb ? const String.fromEnvironment('CLIENT_ID') : dotenv.env['CLIENT_ID'] ?? '';
  final String _tenantId = kIsWeb ? const String.fromEnvironment('TENANT_ID') : dotenv.env['TENANT_ID'] ?? '';
  final List<String> _scopes = ['openid', 'profile', 'email', 'offline_access', 'User.Read', 'Files.ReadWrite.All'];

  final SettingsService settingsService = SettingsService();

  late final Uri _authorizationEndpoint;
  late final Uri _tokenEndpoint;
  late final String redirectUrl;

  AuthProvider() {
    _authorizationEndpoint = Uri.parse('https://login.microsoftonline.com/$_tenantId/oauth2/v2.0/authorize');
    _tokenEndpoint = Uri.parse('https://login.microsoftonline.com/$_tenantId/oauth2/v2.0/token');
    redirectUrl =
        kIsWeb
            ? "${const String.fromEnvironment('HOST')}/redirect.html"
            : "https://login.microsoftonline.com/$_tenantId/oauth2/nativeclient";
  }

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
    return oauth2.Client(_credentials!, identifier: _clientId, onCredentialsRefreshed: (updated) => _saveCredentials(updated));
  }

  // Start authentication flow
  Uri startAuthFlow() {
    setLoading(true);
    _grant = oauth2.AuthorizationCodeGrant(_clientId, _authorizationEndpoint, _tokenEndpoint);
    return _grant!.getAuthorizationUrl(Uri.parse(redirectUrl), scopes: _scopes);
  }

  // Handle authorization code after login
  Future<bool> handleAuthCode(String code) async {
    if (_hasHandledCode) {
      debugPrint("AuthCode already handled. Skipping...");
      return true;
    }
    setLoading(true);
    try {
      final client = await _grant!.handleAuthorizationCode(code);
      _saveCredentials(client.credentials);
      _hasHandledCode = true;
      setLoading(false);
      return true;
    } catch (e) {
      debugPrint("Error handling auth code: $e");
      setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await settingsService.delete("credentials");
    _hasHandledCode = false;
    _credentials = null;
    isLoading = false;
    notifyListeners();
  }

  Future<void> _getCredentials() async {
    try {
      final json = await settingsService.get('credentials') as String;
      final creds = oauth2.Credentials.fromJson(json);
      if (creds.isExpired && kIsWeb) {
        _credentials = null;
        debugPrint("Stored credentials are expired");
      } else {
        _credentials = creds;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error getting credentials: $e");
    }
  }

  Future<void> _saveCredentials(oauth2.Credentials newCredentials) async {
    try {
      _credentials = newCredentials;
      settingsService.init();
      settingsService.put('credentials', newCredentials.toJson());
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
