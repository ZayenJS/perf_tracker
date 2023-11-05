import 'package:sqfentity_gen/sqfentity_gen.dart';

const timestamps = [
  SqfEntityField(
    'created_at',
    DbType.datetime,
    isNotNull: true,
  ),
  SqfEntityField('updated_at', DbType.datetime, defaultValue: null),
];
