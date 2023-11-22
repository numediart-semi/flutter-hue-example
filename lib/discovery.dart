import 'package:flutter/material.dart';
import 'package:flutter_hue/flutter_hue.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  List<String> _bridgeIps = [];
  bool _scanning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discovery'),
        bottom: !_scanning
            ? null
            : const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: LinearProgressIndicator(value: null),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanning ? null : _scan,
        label: const Text('Scan'),
        icon: const Icon(Icons.search),
      ),
      body: ListView.builder(
        itemCount: _bridgeIps.length,
        itemBuilder: (context, index) {
          return Card(
            clipBehavior: Clip.hardEdge,
            child: ListTile(
              title: Text(_bridgeIps[index]),
              onTap: () => _onBridgeSelected(_bridgeIps[index]),
              leading: const Icon(Icons.router),
            ),
          );
        },
      ),
    );
  }

  _scan() async {
    setState(() {
      _scanning = true;
      _bridgeIps = [];
    });
    try {
      List<String> bridgeIps = await BridgeDiscoveryRepo.discoverBridges();
      setState(() => _bridgeIps = bridgeIps);
    } catch (e) {
      print(e);
    } finally {
      setState(() => _scanning = false);
    }
  }

  _onBridgeSelected(String bridgeIp) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bridge Connection'),
          content: Text('You will connect to Bridge with IP: $bridgeIp'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const ElevatedButton(
              onPressed: null,
              child: Text('Connect'),
            ),
          ],
        );
      },
    );
  }
}
