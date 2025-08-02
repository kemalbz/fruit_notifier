import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Fruit Notifier")),
        body: FruitChecker(),
      ),
    );
  }
}

class FruitChecker extends StatefulWidget {
  @override
  _FruitCheckerState createState() => _FruitCheckerState();
}

class _FruitCheckerState extends State<FruitChecker> {
  List<String> valuableFruits = [
    "Cactus Seed",
    "Grape Seed",
    "Mushroom Seed",
    "Pepper Seed",
    "Cacao Seed",
    "Beanstalk Seed",
    "Ember Lily Seed",
    "Sugar Apple Seed",
    "Burning Bud Seed",
    "Giant Pinecone Seed",
    "Elder Strawberry Seed"
  ];
  String lastValuable = "";
  Timer? _timer;
  final player = AudioPlayer();
  final notifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _checkFruits();
    });
  }

  Future<void> _initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await notifications.initialize(settings);
  }

  Future<void> _checkFruits() async {
    final response = await http.get(Uri.parse('https://arcaiuz.com/grow-a-garden-stock'));
    if (response.statusCode == 200) {
      for (var fruit in valuableFruits) {
        if (response.body.contains(fruit) && lastValuable != fruit) {
          _notify(fruit);
          setState(() {
            lastValuable = fruit;
          });
          break;
        }
      }
    }
  }

  Future<void> _notify(String fruitName) async {
    for (int i = 0; i < 3; i++) {
      await player.play(AssetSource('light_fruit.mp3'));
      await Future.delayed(Duration(seconds: 1));
    }

    const android = AndroidNotificationDetails('fruit_channel', 'Fruit Alerts',
        importance: Importance.max, priority: Priority.high);
    const details = NotificationDetails(android: android);
    await notifications.show(0, 'Değerli Meyve!', '$fruitName bulundu!', details);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Uygulama çalışıyor, meyveler kontrol ediliyor..."));
  }
}