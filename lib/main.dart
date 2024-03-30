import 'package:c3_app/pages/login_page.dart';
import 'package:c3_app/services/auth_service.auth.dart';
import 'package:c3_app/services/navigation.service.dart';
import 'package:c3_app/utils.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void main() async {
  await setup();
  runApp( MainApp());
}

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupfirebase();
  await registerServices();
}

class MainApp extends StatelessWidget {
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late AuthService  _authService;

  MainApp({Key? key}) : super(key: key) {
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigationService.navigatorKey,
      routes: _navigationService.routes,
      initialRoute: _authService.user !=  null ? '/home' : '/login',
    );
  }
}
