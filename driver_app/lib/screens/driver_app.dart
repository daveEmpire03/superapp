import 'package:flutter/material.dart';

import '../data/driver_api.dart';
import 'driver_dashboard.dart';
import 'driver_login_screen.dart';

class BokkuDriverApp extends StatefulWidget {
  const BokkuDriverApp({super.key});

  @override
  State<BokkuDriverApp> createState() => _BokkuDriverAppState();
}

class _BokkuDriverAppState extends State<BokkuDriverApp> {
  final DriverApi _api = DriverApi();
  bool _signedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bokku Driver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6D28D9)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F7FB),
      ),
      home: _signedIn
          ? DriverDashboard(api: _api, onLogout: () async {
              await _api.logout();
              if (mounted) setState(() => _signedIn = false);
            })
          : DriverLoginScreen(api: _api, onSignedIn: () {
              if (mounted) setState(() => _signedIn = true);
            }),
    );
  }
}
