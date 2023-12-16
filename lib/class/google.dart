import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workout_performance_tracker/models/performance.dart';
import 'package:workout_performance_tracker/utils/main.dart';

const _scopes = [
  'https://www.googleapis.com/auth/drive.file',
];

class Google {
  static final _googleSignIn = GoogleSignIn(scopes: _scopes);

  static Future<GoogleSignInAccount?> getSignedInAccount() async {
    return _googleSignIn.currentUser;
  }

  static Future<AuthClient?> getAuthenticatedClient() async {
    return _googleSignIn.authenticatedClient();
  }

  static Future<GoogleSignInAccount?> getLoggedUser({
    bool silentlyOnly = false,
  }) async {
    try {
      GoogleSignInAccount? googleUser =
          await getSignedInAccount() ?? await _googleSignIn.signInSilently();

      if (googleUser == null && !silentlyOnly) {
        googleUser = await _googleSignIn.signIn();
      }

      return googleUser;
    } catch (error) {
      print('Error logging in with Google: $error');
    }
  }

  static Future logout() async {
    try {
      if (await getSignedInAccount() == null) {
        return;
      }

      await _googleSignIn.disconnect();
    } catch (error) {
      print('Error logging out with Google: $error');
    }
  }

  static Future driveBackupPerformances() async {
    final data = await AppPerformance.formatForCsv();

    await driveBackup(data);
  }

  static Future driveBackup(String data) async {
    var client = await getAuthenticatedClient();

    if (client == null) {
      return;
    }

    var drive = ga.DriveApi(client);
    ga.File fileToUpload = ga.File();

    final directory = await getApplicationCacheDirectory();
    const fileName = 'WorkoutPerformanceTracker.backup.auto.csv';
    final File file = await File(
      '${directory.path}/$fileName',
    ).writeAsString(data);

    final result =
        (await drive.files.list(q: "name = '$fileName' and trashed = false"));

    if (result.files == null || result.files!.isEmpty) {
      fileToUpload.parents = ['root'];
      fileToUpload.name = basename(file.path);

      await drive.files.create(
        fileToUpload,
        uploadMedia: ga.Media(file.openRead(), file.lengthSync()),
      );
    } else if (result.files!.isNotEmpty) {
      if (result.files!.length > 1) {
        for (var i = 1; i < result.files!.length; i++) {
          await drive.files.delete(result.files![i].id!);
        }
      }

      await drive.files.update(
        fileToUpload,
        result.files!.first.id!,
        uploadMedia: ga.Media(file.openRead(), file.lengthSync()),
      );
    }

    await file.delete();
  }
}
