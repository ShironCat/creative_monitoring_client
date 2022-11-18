import 'dart:collection';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

List<Stack> parseStacks(List<dynamic> jsonList) {
  return jsonList.map((value) => Stack.fromJson(value)).toList();
}

class Stack {
  final String name;
  final int count;

  const Stack({
    required this.name,
    required this.count,
  });

  factory Stack.fromJson(Map<String, dynamic> json) {
    return Stack(name: json['name'] as String, count: json['count'] as int);
  }
}

class Sensor {
  final String name;
  final bool status;
  final List<Stack> value;

  const Sensor({
    required this.name,
    required this.status,
    required this.value,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
        name: json['name'] as String,
        status: json['status'] as bool,
        value: parseStacks(json['value']));
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'Creative Monitoring';
    return MaterialApp(
      home: const SplashScreenPage(
        title: title,
      ),
      darkTheme: ThemeData.dark(),
    );
  }
}

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();

    checkLoginState();
  }

  void checkLoginState() async {
    await Firebase.initializeApp();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: ((context) => const LoginPage())));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: ((context) => const HomePage())));
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailAddressController = TextEditingController();
  final passwordController = TextEditingController();
  String status = '';

  void checkLogin() {
    try {
      FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailAddressController.text,
              password: passwordController.text)
          .then((value) => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage())));
    } catch (e) {
      status = 'Usuário ou senha inválidos';
    }
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
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(
              controller: emailAddressController,
              decoration: const InputDecoration(helperText: 'Username'),
            ),
            TextField(
                controller: passwordController,
                decoration: const InputDecoration(helperText: 'Password')),
            ElevatedButton(
                onPressed: () => checkLogin(), child: const Text('Login')),
            Container(child: status == '' ? null : Text(status))
          ],
        )),
        Expanded(child: Container())
      ]),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selected = '';

  final channel = WebSocketChannel.connect(
    Uri.parse(''),
  );
  final Map<String, Sensor> sensors = HashMap();

  @override
  void initState() {
    super.initState();

    channel.stream.listen((event) {
      final Map<String, dynamic> parsed = jsonDecode(event);
      final sensor = Sensor.fromJson(parsed);

      setState(() {
        sensors[sensor.name] = sensor;
      });
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Creative Monitoring')),
      body: ListView(
          children: sensors.values
              .map((sensor) => Card(
                    child: InkWell(
                      onTap: () {
                        var newSelected = '';

                        if (selected != sensor.name) {
                          newSelected = sensor.name;
                        }

                        setState(() {
                          selected = newSelected;
                        });
                      },
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                CircleAvatar(
                                    backgroundColor: sensor.status
                                        ? Colors.red
                                        : Colors.green),
                                Text(sensor.name)
                              ],
                            ),
                            Visibility(
                                visible: selected == sensor.name,
                                child: Column(
                                  children: [
                                    Column(
                                        children: sensor.value
                                            .map((stack) => Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Image(
                                                        image: AssetImage(
                                                            'assets/images/${stack.name}.png')),
                                                    Text(stack.count.toString())
                                                  ],
                                                ))
                                            .toList()),
                                    ElevatedButton(
                                        onPressed: () {
                                          channel.sink.add(jsonEncode({
                                            'target': sensor.name,
                                            'content': 'toggle'
                                          }));
                                        },
                                        child: const Text('On/Off'))
                                  ],
                                ))
                          ],
                        ),
                      ),
                    ),
                  ))
              .toList()),
    );
  }
}
