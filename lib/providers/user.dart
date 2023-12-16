import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:workout_performance_tracker/class/google.dart';

class UserState {
  final GoogleSignInAccount? currentUser;

  UserState({this.currentUser});
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState());

  void setCurrentUser(GoogleSignInAccount? user) {
    state = UserState(currentUser: user);
  }

  Future<GoogleSignInAccount?> getCurrentUser({
    bool silentlyOnly = false,
  }) async {
    final user = await Google.getLoggedUser(silentlyOnly: silentlyOnly);

    setCurrentUser(user);

    return user;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>(
  (ref) => UserNotifier(),
);
