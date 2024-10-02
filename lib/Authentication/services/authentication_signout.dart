import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../Widgets/snackBar.dart';

class AuthenticationMethodSignOut {
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;

  // Constructor
  AuthenticationMethodSignOut({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  })  : auth = auth ?? FirebaseAuth.instance,
        googleSignIn = googleSignIn ?? GoogleSignIn();

  // SIGN OUT
  Future<void> signOut() async {
    try {
      await auth.signOut();
      await googleSignIn.signOut();
    } catch (e) {
      Utils.showSnackBar("An error occurred while signing out");
    }
  }
}