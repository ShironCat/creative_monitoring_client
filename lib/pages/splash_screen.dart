import 'package:creative_monitoring_client/pages/home.dart';
import 'package:creative_monitoring_client/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    checkLoginState();
  }

  void checkLoginState() async {
    await Firebase.initializeApp();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: ((_) => const Login())));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: ((_) => const Home())));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Icon(Icons.settings, size: 100)),
    );
  }
}
