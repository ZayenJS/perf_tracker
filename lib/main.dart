import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_performance_tracker/providers/exercise.dart';
import 'package:workout_performance_tracker/providers/settings.dart';
import 'package:workout_performance_tracker/screens/tabs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await DbModel().initializeDB();
  // await loadInitialData();

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();

    ref.read(exerciseProvider.notifier).load();
    ref.read(settingsProvider.notifier).load();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        title: 'Workout Performance Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 140, 137, 157),
            error: Color.fromARGB(255, 184, 73, 65),
            onError: Colors.white,
          ),
          useMaterial3: true,
          cardTheme: CardTheme.of(context).copyWith(
            surfaceTintColor: Colors.white,
          ),
          datePickerTheme: DatePickerTheme.of(context).copyWith(
            surfaceTintColor: Colors.white,
          ),
          popupMenuTheme: PopupMenuTheme.of(context).copyWith(
            surfaceTintColor: Colors.white,
          ),
        ),
        home: const TabsScreen(),
      ),
    );
  }
}
