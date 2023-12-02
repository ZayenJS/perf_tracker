import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:workout_performance_tracker/class/google.dart';

class UserState {
  final GoogleSignInAccount? currentUser;
  final bool automaticBackup;

  UserState({this.currentUser, this.automaticBackup = false});
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState());

  void setCurrentUser(GoogleSignInAccount? user) {
    state = UserState(currentUser: user);
  }

  Future<GoogleSignInAccount?> getCurrentUser() async {
    final user = await Google.getLoggedUser();

    setCurrentUser(user);

    return user;
  }

  void setAutomaticBackup(bool automaticBackup) {
    state = UserState(
      currentUser: state.currentUser,
      automaticBackup: automaticBackup,
    );
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>(
  (ref) => UserNotifier(),
);
