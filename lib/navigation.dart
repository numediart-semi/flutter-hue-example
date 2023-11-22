import 'package:flutter_hue_example/bridge.dart';
import 'package:flutter_hue_example/discovery.dart';
import 'package:go_router/go_router.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: _routes,
);

final _routes = [
  GoRoute(
    path: '/',
    builder: (context, state) => DiscoveryScreen(
      onBridgeSelected: (ip) => GoRouter.of(context).goNamed('bridge', queryParameters: {'ip': ip}),
    ),
    routes: [
      GoRoute(
        name: 'bridge',
        path: 'bridge',
        builder: (context, state) => BridgeScreen(ip: state.uri.queryParameters['ip']!),
      ),
    ],
  ),
];
