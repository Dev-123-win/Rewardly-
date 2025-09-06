
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewardly/app/app_theme.dart';
import 'package:rewardly/features/auth/presentation/providers/auth_provider.dart';

import 'app/providers/user_data_provider.dart';
import 'app/routing/app_router.dart';
import 'firebase_options.dart';
import 'shared/services/remote_config_service.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      await RemoteConfigService.getInstance();

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => ThemeProvider()),
            ChangeNotifierProvider(create: (context) => UserDataProvider()),
            ChangeNotifierProvider(create: (context) => AuthProvider()),
          ],
          child: const MyApp(),
        ),
      );
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
      runApp(ErrorApp(error: e, stackTrace: s));
    }
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          routerConfig: router,
          title: 'Rewardly',
          theme: RewardlyTheme.lightTheme,
          darkTheme: RewardlyTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class ErrorApp extends StatelessWidget {
  final Object error;
  final StackTrace stackTrace;

  const ErrorApp({super.key, required this.error, required this.stackTrace});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Error',
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 80),
                  const SizedBox(height: 20),
                  Text(
                    'Fatal Error',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Something went wrong during app startup. Please report this issue.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      'Error Details:\n$error\n\nStack Trace:\n$stackTrace',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
