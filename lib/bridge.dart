import 'package:flutter/material.dart';

class BridgeScreen extends StatefulWidget {
  final String ip;

  const BridgeScreen({Key? key, required this.ip}) : super(key: key);

  @override
  State<BridgeScreen> createState() => _BridgeScreenState();
}

class _BridgeScreenState extends State<BridgeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bridge')),
      body: Container(),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSnackBar());
  }

  void _showSnackBar() {
    final snackBar = SnackBar(
      content: Text('Connecting to bridge (IP: ${widget.ip})'),
      dismissDirection: DismissDirection.none,
      duration: const Duration(days: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
