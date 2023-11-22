import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hue/flutter_hue.dart';
import 'package:go_router/go_router.dart';

class BridgeScreen extends StatefulWidget {
  final String ip;

  const BridgeScreen({Key? key, required this.ip}) : super(key: key);

  @override
  State<BridgeScreen> createState() => _BridgeScreenState();
}

class _BridgeScreenState extends State<BridgeScreen> {
  Bridge? _bridge;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bridge')),
      body: _bridge == null
          ? Container()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                  child: Text(
                    "Bridge",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text("Bridge ID"),
                          subtitle: Text(_bridge!.bridgeId),
                        ),
                        ListTile(
                          title: const Text("IP Address"),
                          subtitle: Text(_bridge!.ipAddress!),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connect(widget.ip));
  }

  void _connect(String ip) async {
    _showSnackBar(ip);
    final savedBridges = await BridgeDiscoveryRepo.fetchSavedBridges();
    Bridge? bridge = savedBridges.firstWhereOrNull((element) => element.ipAddress == ip);

    if (bridge == null) {
      await _showPairingBridge();
      bridge = await BridgeDiscoveryRepo.firstContact(
        bridgeIpAddr: ip,
        controller: DiscoveryTimeoutController(),
      );
    }
    if (bridge == null) {
      _hideSnackBar();
      await _showPairingFailed();
      return _popBack();
    }
    setState(() {
      _bridge = bridge;
    });

    _hideSnackBar();
  }

  void _showSnackBar(ip) {
    final snackBar = SnackBar(
      content: Text('Connecting to bridge (IP: $ip)'),
      dismissDirection: DismissDirection.none,
      duration: const Duration(days: 1),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _hideSnackBar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  void _popBack() {
    GoRouter.of(context).pop();
  }

  _showPairingFailed() => showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Pairing Failed'),
            content: const Text('Unable to pair with bridge.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

  _showPairingBridge() => showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Pairing Bridge'),
            content: const Text(
              "The bridge is not paired with this app. "
              "After pressing 'Start Pairing', press the central button on the bridge.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Start Pairing'),
              ),
            ],
          );
        },
      );
}
