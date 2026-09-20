import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/data_service.dart';
import 'services/settings_service.dart';
import 'services/progress_service.dart';
import 'services/audio_service.dart';
import 'services/route_observer.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NihongoTrainerApp());
}

class NihongoTrainerApp extends StatelessWidget {
  const NihongoTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsService()),
        ChangeNotifierProvider(create: (_) => ProgressService()),
        ChangeNotifierProvider(create: (_) => AudioService()),
      ],
      child: MaterialApp(
        title: 'Nihongo Trainer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        navigatorObservers: [appRouteObserver],
        home: const _AppLoader(),
      ),
    );
  }
}

/// Loads the bundled JSON data and saved settings once before showing the
/// home screen, with a small branded splash while that happens (it's fast
/// -- well under a second on-device -- but never assume zero).
class _AppLoader extends StatefulWidget {
  const _AppLoader();

  @override
  State<_AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<_AppLoader> {
  late final Future<void> _ready;

  @override
  void initState() {
    super.initState();
    _ready = _load();
  }

  Future<void> _load() async {
    await Future.wait([
      DataService.instance.load(),
      context.read<SettingsService>().load(),
      context.read<ProgressService>().load(),
      context.read<AudioService>().load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SplashScreen();
        }
        if (snapshot.hasError) {
          return _ErrorScreen(error: snapshot.error.toString());
        }
        return const HomeScreen();
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('文',
                style: AppTheme.jp(64, weight: FontWeight.w700)
                    .copyWith(color: AppColors.accent)),
            const SizedBox(height: 18),
            const CircularProgressIndicator(color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String error;
  const _ErrorScreen({required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Something went wrong loading the app data:\n$error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.bad),
          ),
        ),
      ),
    );
  }
}
