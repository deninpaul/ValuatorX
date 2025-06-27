import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/pages/home_screen.dart';
import 'package:valuatorx/pages/login/login_screen.dart';
import 'package:valuatorx/pages/splash_screen/splash_screen.dart';
import 'package:valuatorx/providers/auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:valuatorx/providers/land_rate_provider.dart';
import 'package:valuatorx/providers/location_provider.dart';
import 'package:valuatorx/providers/media_provider.dart';
import 'package:valuatorx/providers/valuation_provider.dart';
import 'package:valuatorx/utils/common.dart';
import 'package:valuatorx/utils/theme.dart';
import 'package:valuatorx/utils/web_utils/web_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  initWeb();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LandRateProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => ValuationProvider()),
        ChangeNotifierProvider(create: (_) => MediaProvider()),
      ],
      child: MaterialApp(
        title: 'ValuatorX',
        color: Colors.white,
        theme: globalTheme(context),
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
        initialRoute: '/',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [FlutterQuillLocalizations.delegate],
        scaffoldMessengerKey: scaffoldMessengerKey,
      ),
    );
  }
}
