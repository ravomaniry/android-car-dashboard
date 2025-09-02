import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dashboard_screen.dart';
import 'services/dashboard_state.dart';
import 'services/bluetooth_service.dart';
import 'services/gps_service.dart';
import 'services/event_manager.dart';

void main() {
  runApp(const CarDashboardApp());
}

class CarDashboardApp extends StatelessWidget {
  const CarDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DashboardState()),
        ChangeNotifierProvider(create: (context) => EventManager()),
        ChangeNotifierProxyProvider<DashboardState, BluetoothService>(
          create: (context) => BluetoothService(Provider.of<DashboardState>(context, listen: false)),
          update: (context, dashboardState, bluetoothService) => bluetoothService ?? BluetoothService(dashboardState),
        ),
        ChangeNotifierProxyProvider<DashboardState, GpsService>(
          create: (context) => GpsService(Provider.of<DashboardState>(context, listen: false)),
          update: (context, dashboardState, gpsService) => gpsService ?? GpsService(dashboardState),
        ),
      ],
      child: MaterialApp(
        title: 'Car Dashboard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: 'FiraCode',
        ),
        home: const FullscreenDashboard(),
      ),
    );
  }
}

class FullscreenDashboard extends StatefulWidget {
  const FullscreenDashboard({super.key});

  @override
  State<FullscreenDashboard> createState() => _FullscreenDashboardState();
}

class _FullscreenDashboardState extends State<FullscreenDashboard> {
  @override
  void initState() {
    super.initState();
    // Hide system UI for fullscreen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Lock orientation to landscape
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  void dispose() {
    // Restore system UI when leaving
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen();
  }
}
