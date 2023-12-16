import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_performance_tracker/class/google.dart';
import 'package:workout_performance_tracker/class/perf_popup_return.dart';
import 'package:workout_performance_tracker/class/performance_detail.dart';
import 'package:workout_performance_tracker/class/performance_source.dart';
import 'package:workout_performance_tracker/models/performance.dart';
import 'package:workout_performance_tracker/providers/home.dart';
import 'package:workout_performance_tracker/providers/search.dart';
import 'package:workout_performance_tracker/providers/settings.dart';
import 'package:workout_performance_tracker/providers/user.dart';
import 'package:workout_performance_tracker/screens/exercise.dart';
import 'package:workout_performance_tracker/screens/home.dart';
import 'package:workout_performance_tracker/screens/settings.dart';
import 'package:workout_performance_tracker/utils/main.dart';
import 'package:workout_performance_tracker/widgets/home/app_bar.dart';
import 'package:workout_performance_tracker/widgets/home/floating_action_button.dart';
import 'package:workout_performance_tracker/widgets/perf_popup.dart';

class TabsScreen extends ConsumerStatefulWidget {
  const TabsScreen({super.key});

  @override
  ConsumerState<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends ConsumerState<TabsScreen>
    with TickerProviderStateMixin {
  final List<PerformanceDetail> _results = [];
  int _sortColumnIndex = 3;
  bool _sortAscending = false;

  late PerformanceSource _data;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      initialIndex: 0,
      vsync: this,
    );

    _tabController.addListener(() {
      final searchNotifier = ref.read(searchProvider.notifier);

      setState(() {
        _sortColumnIndex = 3;
        _sortAscending = false;
        _results.clear();
        _updateTableData();
        searchNotifier.reset();
      });
    });

    _updateTableData();

    ref
        .read(userProvider.notifier)
        .getCurrentUser(silentlyOnly: true)
        .then((user) async {
      if (user == null) {
        return;
      }

      final isBackupEnabled = ref.read(settingsProvider).autoBackup;

      if (!isBackupEnabled) {
        return;
      }

      Google.driveBackupPerformances();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  void _onRowTap(PerformanceDetail data) async {
    final result = await showDialog<PerfPopupReturn>(
      context: context,
      builder: (BuildContext context) {
        return PerfPopup(data: data);
      },
    );

    if (result == null) {
      return;
    }

    final perf = result.data;

    if (perf == null) {
      return;
    }

    if (result.deleted) {
      _results.removeWhere((p) => p.id == perf.id);
      _updateTableData();
      _onSort(_sortColumnIndex, _sortAscending);
      return;
    }

    final perfIndex = _results.indexWhere((p) => p.id == perf.id);

    setState(() {
      if (perfIndex == -1) {
        _results.add(perf);
      } else {
        _results[perfIndex] = perf;
      }

      _updateTableData();
      _onSort(_sortColumnIndex, _sortAscending);
    });
  }

  void _updateTableData() {
    _data = PerformanceSource(data: _results, onTap: _onRowTap);
  }

  void _onSort(int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;

      if (columnIndex == 3) {
        _data.sortDate(
          (PerformanceDetail p) => p.date,
          ascending,
        );
      } else {
        _data.sortNumeric<num>(
          (PerformanceDetail p) {
            switch (columnIndex) {
              case 0:
                return p.sets;
              case 1:
                return p.reps;
              case 2:
                return p.weight;
              default:
                return p.sets;
            }
          },
          ascending,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      appBar: _tabController.index <= 1 ? const HomeAppBar() : null,
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          HomeScreen(
            params: HomeParams(
              results: _results,
              sortAscending: _sortAscending,
              sortColumnIndex: _sortColumnIndex,
              onRowTap: _onRowTap,
              onSort: _onSort,
            ),
            clearResults: () => _results.clear(),
            updateSearchResults: (List<PerformanceDetail> results) {
              setState(() {
                _results.addAll(results);
                _updateTableData();
                _sortAscending = false;
                _sortColumnIndex = 3;
              });
            },
          ),
          const ExerciseScreen(),
          const SettingsScreen(),
        ],
      ),
      floatingActionButton: homeState.isImporting || _tabController.index > 0
          ? null
          : HomeFloatingActionButton(
              updateSearchResults: (perf) {
                if (_results.isEmpty) {
                  return;
                }

                final searchedExerciseName =
                    ref.read(searchProvider).exerciseNameController.text;

                final isSameExercise = searchedExerciseName.isNotEmpty &&
                    searchedExerciseName == perf.name;

                if (!isSameExercise) {
                  return;
                }

                final perfIndex = _results.indexWhere((p) => p.id == perf.id);

                setState(() {
                  if (perfIndex == -1) {
                    _results.add(perf);
                  } else {
                    _results[perfIndex] = perf;
                  }

                  _updateTableData();
                  _onSort(_sortColumnIndex, _sortAscending);
                });
              },
            ),
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
            icon: Icon(Icons.fitness_center),
            label: 'Exercises',
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
