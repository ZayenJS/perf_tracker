import 'package:csv/csv.dart';
import 'package:workout_performance_tracker/models/exercise.dart';
import 'package:workout_performance_tracker/models/model.dart' as models;
import 'package:workout_performance_tracker/models/timestamps.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';

const performancesTable = SqfEntityTable(
  tableName: 'performances',
  primaryKeyName: 'id',
  primaryKeyType: PrimaryKeyType.integer_auto_incremental,
  useSoftDeleting: false,
  modelName: "Performance",
  fields: [
    SqfEntityField('reps', DbType.integer, isNotNull: true),
    SqfEntityField('sets', DbType.integer, isNotNull: true),
    SqfEntityField('weight', DbType.real, isNotNull: true),
    SqfEntityFieldRelationship(
      parentTable: exercisesTable,
      fieldName: "exercise_id",
      deleteRule: DeleteRule.CASCADE,
      isNotNull: true,
      relationType: RelationType.ONE_TO_MANY,
    ),
    ...timestamps,
  ],
);

class AppPerformance {
  static Future<String> formatForCsv() async {
    final performances =
        await models.Performance().select().toList(preload: true);
    final data = performances
        .map(
            (e) => [e.plExercise!.name, e.sets, e.reps, e.weight, e.created_at])
        .toList();

    ListToCsvConverter converter = const ListToCsvConverter();
    final csvData = converter.convert([
      ["name", "sets", "reps", "weight", "created_at"],
      ...data
    ]);
    print(csvData);
    return csvData;
  }
}
