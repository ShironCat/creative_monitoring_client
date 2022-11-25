import 'package:creative_monitoring_client/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailAddressController = TextEditingController();
  final passwordController = TextEditingController();

  void checkLogin() {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: emailAddressController.text,
            password: passwordController.text)
        .then((value) => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const Home())))
        .catchError(
            (_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Usuário ou senha inválidos.',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.red,
                )));
  }

  @override
  void dispose() {
    emailAddressController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Flex(direction: Axis.vertical, children: [
        Expanded(
            flex: 70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextField(
                  textInputAction: TextInputAction.next,
                  controller: emailAddressController,
                  decoration: const InputDecoration(helperText: 'Username'),
                ),
                TextField(
                    onSubmitted: (_) => checkLogin(),
                    textInputAction: TextInputAction.done,
                    obscureText: true,
                    controller: passwordController,
                    decoration: const InputDecoration(helperText: 'Password')),
                ElevatedButton(
                    onPressed: () => checkLogin(), child: const Text('Login'))
              ],
            )),
        Expanded(flex: 30, child: Container())
      ]),
    );
  }
}
