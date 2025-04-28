import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valuatorx/pages/home_screen.dart';
import 'package:valuatorx/pages/land_rate/land_rate_form.dart';
import 'package:valuatorx/pages/login/login_screen.dart';
import 'package:valuatorx/pages/splash_screen/splash_screen.dart';
import 'package:valuatorx/providers/auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:valuatorx/providers/land_rate_provider.dart';
import 'package:valuatorx/providers/location_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
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
      ],
      child: MaterialApp(
        title: 'Microsoft Auth Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/land_rate/add': (context) => const LandRateForm(),
          '/land_rate/edit': (context) => const LandRateForm(editMode: true),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
