import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_performance_tracker/class/performance_detail.dart';
import 'package:workout_performance_tracker/class/performance_source.dart';
import 'package:workout_performance_tracker/models/model.dart';

class HomeState {
  final bool isImporting;
  final bool isLoading;

  HomeState({
    this.isImporting = false,
    this.isLoading = false,
  });
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(HomeState());

  void setImporting(bool isImporting) {
    state = HomeState(
      isImporting: isImporting,
      isLoading: state.isLoading,
    );
  }

  void setLoading(bool isLoading) {
    state = HomeState(
      isImporting: state.isImporting,
      isLoading: isLoading,
    );
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(),
);
