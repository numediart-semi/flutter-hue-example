import 'package:flutter/material.dart';
import 'package:flutter_hue_example/navigation.dart';

class FlutterHueApp extends StatelessWidget {
  const FlutterHueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Hue',
      theme: ThemeData(
        unselectedWidgetColor: Colors.blue,
        useMaterial3: true,
      ),
      routerConfig: goRouter,
    );
  }
}
