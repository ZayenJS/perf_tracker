import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_performance_tracker/class/google.dart';
import 'package:workout_performance_tracker/models/performance.dart';
import 'package:workout_performance_tracker/providers/settings.dart';
import 'package:workout_performance_tracker/providers/user.dart';
import 'package:workout_performance_tracker/utils/main.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final userNotifier = ref.read(userProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            userState.currentUser == null
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      surfaceTintColor: Colors.white,
                    ),
                    onPressed: () async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final theme = Theme.of(context);

                      try {
                        final user = await Google.getLoggedUser();
                        userNotifier.setCurrentUser(user);
                      } catch (e) {
                        const message = 'Error logging in with Google';

                        showSnackBar(scaffoldMessenger, theme, message);
                      }
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image(
                          image: AssetImage("assets/images/google.png"),
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 8.0),
                        Text('Login with Google'),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      const SizedBox(height: 8.0),
                      Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: CircleAvatar(
                                minRadius: 50,
                                maxRadius: 75,
                                backgroundImage: userState
                                            .currentUser!.photoUrl ==
                                        null
                                    ? Image.asset("assets/images/profile.png")
                                        .image
                                    : NetworkImage(
                                        userState.currentUser!.photoUrl!,
                                      ),
                              ),
                            ),
                            ListTile(
                              title: Text(
                                userState.currentUser!.displayName!,
                                textAlign: TextAlign.center,
                              ),
                              subtitle: Text(
                                userState.currentUser!.email,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Divider(),
                            const Padding(
                              padding: EdgeInsets.only(
                                left: 16.0,
                              ),
                              child: Text(
                                'Backup',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SwitchListTile(
                              value: settings.autoBackup,
                              onChanged: (value) async {
                                settingsNotifier.setAutoBackup(value);

                                if (value) {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  await Google.driveBackupPerformances();

                                  setState(() {
                                    _isLoading = false;
                                  });

                                  showSnackBar(
                                    scaffoldMessenger,
                                    theme,
                                    "Backup to Google Drive successful",
                                  );
                                }
                              },
                              title: const Text('Automatic Backup'),
                              subtitle: const Text(
                                'Automatically backup your data to Google Drive',
                              ),
                            ),
                            ListTile(
                              leading: Image.asset(
                                "assets/images/google-drive.png",
                                width: 24,
                                height: 24,
                              ),
                              title: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : const Text('Backup to Google Drive'),
                              onTap: () async {
                                final scaffoldMessenger =
                                    ScaffoldMessenger.of(context);
                                final theme = Theme.of(context);

                                try {
                                  setState(() {
                                    _isLoading = true;
                                  });

                                  await Google.driveBackupPerformances();

                                  setState(() {
                                    _isLoading = false;
                                  });

                                  showSnackBar(
                                    scaffoldMessenger,
                                    theme,
                                    "Backup to Google Drive successful",
                                  );
                                } catch (e) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  final message =
                                      'Error backing up with Google: $e';

                                  showSnackBar(
                                      scaffoldMessenger, theme, message);
                                }
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.logout),
                              title: const Text('Logout'),
                              onTap: () async {
                                final scaffoldMessenger =
                                    ScaffoldMessenger.of(context);
                                final theme = Theme.of(context);

                                try {
                                  await Google.logout();
                                  userNotifier.setCurrentUser(null);
                                } catch (e) {
                                  final message =
                                      'Error logging out with Google: $e';

                                  showSnackBar(
                                      scaffoldMessenger, theme, message);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
