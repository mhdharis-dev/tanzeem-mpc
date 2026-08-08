import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/providers/app_state.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TanzeemApp());
}

class TanzeemApp extends StatefulWidget {
  const TanzeemApp({super.key});

  @override
  State<TanzeemApp> createState() => _TanzeemAppState();
}

class _TanzeemAppState extends State<TanzeemApp> {
  late final AppState _appState;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _appState = AppState();
    _router = AppRouter.createRouter(_appState);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>.value(
      value: _appState,
      child: Selector<AppState, bool>(
        selector: (_, state) => state.isDarkMode,
        builder: (context, isDarkMode, child) {
          return MaterialApp.router(
            title: 'Tanzeem - Smart Meelad Program Management',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
