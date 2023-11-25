import 'package:workout_performance_tracker/models/exercise.dart';
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
