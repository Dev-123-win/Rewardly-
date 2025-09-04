import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rewardly/app_lifecycle_reactor.dart';
import 'package:rewardly/providers/auth_provider.dart';
import 'package:rewardly/providers/user_data_provider.dart';
import 'package:rewardly/router.dart';
import 'package:rewardly/services/ad_service.dart';
import 'package:rewardly/theme/theme_provider.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // By default, persistence is enabled on mobile.
  // To make it work on web as well, we explicitly enable it.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AdService _adService;
  late final AuthProvider _authProvider;
  late final UserDataProvider _userDataProvider;
  late final ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
    _adService = AdService();
    AppLifecycleReactor(appOpenAdManager: _adService);
    _authProvider = AuthProvider();
    _userDataProvider = UserDataProvider();
    _themeProvider = ThemeProvider();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _userDataProvider),
        ChangeNotifierProvider.value(value: _themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Rewardly',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
