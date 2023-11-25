import 'package:workout_performance_tracker/class/performance_detail.dart';

class PerfPopupReturn {
  final PerformanceDetail? data;
  final bool deleted;

  const PerfPopupReturn({
    this.data,
    this.deleted = false,
  });
}
