import 'package:perf_tracker/models/model.dart';

class PerformanceDetail {
  final int? id;
  final String name;
  final int sets;
  final int reps;
  final double weight;
  final DateTime date;

  PerformanceDetail({
    this.id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.date,
  });

  factory PerformanceDetail.fromList(List<dynamic> list) {
    return PerformanceDetail(
      name: list[0].toString(),
      sets: list[1],
      reps: list[2],
      weight: list[3],
      date: DateTime.parse(list[4]),
    );
  }

  static List<PerformanceDetail> forExercise(
    String exerciseName,
    List<Performance> perfs,
  ) {
    return perfs
        .map((p) => PerformanceDetail(
              id: p.id,
              name: exerciseName,
              sets: p.sets!,
              reps: p.reps!,
              weight: p.weight!,
              date: p.created_at!,
            ))
        .toList();
  }
}
