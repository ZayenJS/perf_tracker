import 'package:sqfentity_gen/sqfentity_gen.dart';
import 'package:perf_tracker/models/timestamps.dart';

const exercisesTable = SqfEntityTable(
  tableName: 'exercises',
  primaryKeyName: 'id',
  primaryKeyType: PrimaryKeyType.integer_auto_incremental,
  useSoftDeleting: false,
  modelName: "Exercise",
  fields: [
    SqfEntityField('name', DbType.text, isNotNull: true),
    ...timestamps,
  ],
);
