import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_performance_tracker/data/data.dart';
import 'package:workout_performance_tracker/models/model.dart';
import 'package:workout_performance_tracker/providers/exercise.dart';
import 'package:workout_performance_tracker/screens/home.dart';

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
  const App({Key? key}) : super(key: key);

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();

    ref.read(exerciseProvider.notifier).load();

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
            seedColor: Colors.deepPurple,
            error: const Color.fromARGB(255, 183, 47, 37),
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
        home: const HomeScreen(),
      ),
    );
  }
}
