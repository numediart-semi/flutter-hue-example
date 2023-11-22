import 'package:flutter/material.dart';
import 'package:flutter_hue_example/discovery.dart';

class FlutterHueApp extends StatelessWidget {
  const FlutterHueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Hue',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DiscoveryScreen(),
    );
  }
}
