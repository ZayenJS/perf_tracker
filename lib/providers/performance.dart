import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_performance_tracker/models/model.dart';

enum PerformanceType { none }

class PerformanceState {}

class PerformanceNotifier extends StateNotifier<PerformanceState> {
  PerformanceNotifier()
      : super(
          PerformanceState(),
        );

  Future addPerf(Performance performance) async {
    if (performance.id != null) {
      throw "An unexpected error occured";
    }

    if (performance.exercise_id == null) {
      throw "Exercise name is required";
    }

    if (performance.sets == null) {
      throw "Sets is required";
    }

    if (performance.reps == null) {
      throw "Reps is required";
    }

    if (performance.weight == null) {
      throw "Weight is required";
    }

    await performance.save();
  }

  Future updatePerf(Performance performance) async {
    if (performance.id == null) {
      throw "An unexpected error occured";
    }

    if (performance.exercise_id == null) {
      throw "Exercise name is required";
    }

    if (performance.sets == null) {
      throw "Sets is required";
    }

    if (performance.reps == null) {
      throw "Reps is required";
    }

    if (performance.weight == null) {
      throw "Weight is required";
    }

    await performance.save();
  }

  Future<List<Performance>> search({
    int? exerciseId,
    String? reps,
    String? sets,
    String? weight,
    String? orderBy,
  }) async {
    PerformanceFilterBuilder queryBuilder = Performance().select().where(
          "exercise_id = ?",
          parameterValue: exerciseId,
        );

    if (reps != null && reps != "") {
      queryBuilder = queryBuilder.and.where(
        "reps = ?",
        parameterValue: reps,
      );
    }

    if (sets != null && sets != "") {
      queryBuilder = queryBuilder.and.where(
        "sets = ?",
        parameterValue: sets,
      );
    }

    if (weight != null && weight != "") {
      queryBuilder = queryBuilder.and.where(
        "weight = ?",
        parameterValue: weight,
      );
    }

    if (orderBy != null && orderBy != "") {
      final orders = orderBy.split(",");

      for (final order in orders) {
        final orderParts = order.split(":");
        final orderBy = orderParts[0];
        final isDesc =
            orderParts.length > 1 && orderParts[1].toLowerCase() == "desc";

        if (isDesc) {
          queryBuilder = queryBuilder.orderByDesc(orderBy);
        } else {
          queryBuilder = queryBuilder.orderBy(orderBy);
        }
      }
    }

    final performances = await queryBuilder.toList();

    return performances;
  }

  Future<bool> deletePerf(int id) async {
    final result = await Performance()
        .select()
        .where("id = ?", parameterValue: id)
        .delete(true);

    return result.success;
  }
}

final performanceProvider =
    StateNotifierProvider<PerformanceNotifier, PerformanceState>(
  (ref) => PerformanceNotifier(),
);
