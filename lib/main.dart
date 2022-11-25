import 'package:creative_monitoring_client/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Creative Monitoring';
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MaterialApp(
      home: const SplashScreen(
        title: title,
      ),
      darkTheme: ThemeData.dark(),
    );
  }
}
