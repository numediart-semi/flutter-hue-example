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
  List<Device> _devices = [];
  late HueNetwork _network;
  bool _refreshing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bridge'),
        bottom: !_refreshing
            ? null
            : const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: LinearProgressIndicator(value: null),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshing ? null : _refresh,
        child: const Icon(Icons.refresh),
      ),
      body: _bridge == null
          ? Container()
          : SingleChildScrollView(
              child: Column(
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
                  ),
                  _devices.isEmpty
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                          child: Text(
                            "Devices",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      final light = getLight(device);
                      final dimmer = getDimmer(device);
                      final bridge = getBridge(device);

                      IconData leading = Icons.question_mark;
                      VoidCallback? onTap;
                      if (light != null) {
                        leading = light.on.isOn ? Icons.lightbulb : Icons.lightbulb_outline;
                        onTap = () {
                          light.on.isOn = !light.on.isOn;
                          _network.put();
                          setState(() {});
                        };
                      } else if (dimmer != null) {
                        leading = Icons.settings_remote;
                      } else if (bridge != null) {
                        leading = Icons.router;
                      }
                      return Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Card(
                          clipBehavior: Clip.hardEdge,
                          child: ListTile(
                            title: Text(device.metadata.name),
                            subtitle: Text(device.productData.productName),
                            leading: Icon(leading),
                            onTap: onTap,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
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
      _network = HueNetwork(bridges: [_bridge!]);
    });
    await _refresh();
    _hideSnackBar();
  }

  _refresh() async {
    if (_bridge == null) return;
    setState(() => _refreshing = true);
    await _network.fetchAll();
    setState(() {
      _devices = _network.devices;
    });
    setState(() => _refreshing = false);
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

  Light? getLight(Device device) => _network.lights.where((element) => element.owner.id == device.id).firstOrNull;

  Button? getDimmer(Device device) => _network.buttons.where((element) => element.owner.id == device.id).firstOrNull;

  Bridge? getBridge(Device device) => _network.bridges.where((element) => element.owner.id == device.id).firstOrNull;
}
