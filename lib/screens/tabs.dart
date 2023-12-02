import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_performance_tracker/class/google.dart';
import 'package:workout_performance_tracker/models/performance.dart';
import 'package:workout_performance_tracker/providers/home.dart';
import 'package:workout_performance_tracker/providers/user.dart';
import 'package:workout_performance_tracker/screens/home.dart';
import 'package:workout_performance_tracker/screens/settings.dart';
import 'package:workout_performance_tracker/widgets/home/app_bar.dart';
import 'package:workout_performance_tracker/widgets/home/floating_action_button.dart';

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends ConsumerState<TabsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _activeScreen = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 2,
      initialIndex: 0,
      vsync: this,
    );

    ref.read(userProvider.notifier).getCurrentUser().then((user) async {
      if (user == null) {
        return;
      }

      final data = await Performance.formatForCsv();

      final isBackupEnabled = ref.read(userProvider).automaticBackup;

      if (!isBackupEnabled) {
        return;
      }

      Google.driveBackup(data);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      appBar: _tabController.index == 0 ? const HomeAppBar() : null,
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: const [
          HomeScreen(),
          SettingsScreen(),
        ],
      ),
      floatingActionButton: homeState.isImporting || _tabController.index == 1
          ? null
          : const HomeFloatingActionButton(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabController.index,
        onTap: (index) {
          setState(() {
            _tabController.animateTo(
              index,
              duration: const Duration(milliseconds: 0),
            );
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
