import 'dart:convert';
import 'package:workout_performance_tracker/models/exercise.dart';
import 'package:workout_performance_tracker/models/performance.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sqfentity/sqfentity.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';
import 'package:workout_performance_tracker/models/settings.dart';

part 'model.g.dart';

const seqIdentity = SqfEntitySequence(
  sequenceName: 'identity',
);

@SqfEntityBuilder(dbModel)
const dbModel = SqfEntityModel(
  databaseName: 'workout_performance_tracker.db',
  databaseTables: [
    exercisesTable,
    performancesTable,
    settingsTable,
  ],
  sequences: [seqIdentity],
  bundledDatabasePath: null,
);
