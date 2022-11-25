import 'dart:collection';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:creative_monitoring_client/models/sensor.dart';
import 'package:creative_monitoring_client/pages/login.dart';
import 'package:creative_monitoring_client/pages/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late FirebaseFirestore db;
  late FirebaseAuth auth;

  String selected = '';

  late WebSocketChannel channel;
  final Map<String, Sensor> sensors = HashMap();

  @override
  void initState() {
    super.initState();
    initialSetup();
  }

  void initialSetup() async {
    db = FirebaseFirestore.instance;
    auth = FirebaseAuth.instance;

    final userUID = auth.currentUser!.uid;
    final userSettings = await db.collection('user').doc(userUID).get();
    final server = await userSettings.data()?['servers'][0].get();

    final serverIP = server.data()?['ip'];
    final serverPort = server.data()?['port'];

    channel = WebSocketChannel.connect(
      Uri.parse('ws://$serverIP:$serverPort/client'),
    );

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
      appBar: AppBar(actions: [
        IconButton(
            onPressed: () {
              auth.signOut().then((_) => Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: ((_) => const Login()))));
            },
            icon: const Icon(Icons.person))
      ], title: const Text('Creative Monitoring')),
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
                        height: selected != sensor.name
                            ? MediaQuery.of(context).size.height / 10
                            : null,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  flex: 30,
                                  child: CircleAvatar(
                                      backgroundColor: sensor.status
                                          ? Colors.red
                                          : Colors.green),
                                ),
                                Expanded(
                                    flex: 70,
                                    child: Text(
                                      sensor.name,
                                      textAlign: TextAlign.center,
                                    ))
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
                                                          .spaceAround,
                                                  children: [
                                                    Image(
                                                        image: AssetImage(
                                                            'assets/images/${stack.name}.png')),
                                                    Text(
                                                        'x ${stack.count.toString().padLeft(2, '0')}')
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
