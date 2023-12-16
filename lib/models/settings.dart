import 'package:sqfentity_gen/sqfentity_gen.dart';
import 'package:workout_performance_tracker/models/timestamps.dart';

const settingsTable = SqfEntityTable(
  tableName: 'settings',
  primaryKeyName: 'id',
  primaryKeyType: PrimaryKeyType.integer_auto_incremental,
  useSoftDeleting: false,
  modelName: "Setting",
  fields: [
    SqfEntityField('auto_backup', DbType.bool, defaultValue: false),
    ...timestamps,
  ],
);
