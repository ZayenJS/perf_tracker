import 'dart:convert';
import 'package:perf_tracker/models/exercise.dart';
import 'package:perf_tracker/models/performance.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sqfentity/sqfentity.dart';
import 'package:sqfentity_gen/sqfentity_gen.dart';

part 'model.g.dart';

const seqIdentity = SqfEntitySequence(
  sequenceName: 'identity',
);

@SqfEntityBuilder(dbModel)
const dbModel = SqfEntityModel(
  databaseName: 'perf_tracker.db',
  databaseTables: [
    exercisesTable,
    performancesTable,
  ],
  sequences: [seqIdentity],
  bundledDatabasePath: null,
);