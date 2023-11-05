import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:perf_tracker/data/data.dart';
import 'package:perf_tracker/models/model.dart';
import 'package:perf_tracker/providers/exercise.dart';
import 'package:perf_tracker/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DbModel().initializeDB();

  await loadInitialData();

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
    ref.read(exerciseProvider.notifier).load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          cardTheme: CardTheme.of(context).copyWith(
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
