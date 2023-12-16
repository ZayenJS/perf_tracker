import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_performance_tracker/models/model.dart';

class SettingsState {
  final bool autoBackup;

  SettingsState({required this.autoBackup});
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState(autoBackup: false));

  Future load() async {
    Setting? settings = await Setting().select().toSingle();

    if (settings == null) {
      await Setting(
        id: 1,
        auto_backup: false,
        created_at: DateTime.now(),
        updated_at: null,
      ).upsert();

      settings = await Setting().select().toSingle() as Setting;
    }

    state = SettingsState(autoBackup: settings.auto_backup ?? false);
  }

  void setAutoBackup(bool value) async {
    state = SettingsState(autoBackup: value);

    final settings = await Setting().select().toSingle();

    await Setting(
      id: settings?.id ?? 1,
      auto_backup: value,
      created_at: settings?.created_at ?? DateTime.now(),
      updated_at: DateTime.now(),
    ).upsert();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
