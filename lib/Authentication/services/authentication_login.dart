import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationMethodLogIn {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final user = FirebaseAuth.instance.currentUser;

  // LOG IN with Email and Password
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return "Please enter both your email and password.";
    }

    try {
      // Logging in user with email and password
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the logged-in user
      User user = userCredential.user!;

      // Check if user document exists in Firestore
      DocumentSnapshot userDoc =
          await firestore.collection("users").doc(user.uid).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;

        // Check for "roles" field and if "car_owner" is present
        List<dynamic>? roles = userData['roles'];
        if (roles?.contains('service_provider') ?? false) {
          return "SUCCESS";
        } else {
          return "You are not registered as a service provider. Please use the appropriate account.";
        }
      } else {
        return "No account found. Please register as a car owner.";
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return "No account found with this email. Please check or sign up.";
        case 'wrong-password':
          return "Incorrect password. Please try again.";
        case 'invalid-email':
          return "The email address format is not valid. Please check and try again.";
        case 'user-disabled':
          return "This account has been disabled. Please contact support.";
        case 'invalid-credential':
          return "The entered email/password is invalid. Please check your inputs.";
        default:
          return e.message ?? "An unknown error occurred. Please try again.";
      }
    } catch (e) {
      return "Something went wrong. Please try again later.";
    }
  }

  // Handles Google Log-In and checks user role
  Future<String> logInWithGoogle() async {
    try {
      // Ensure the user is signed out before starting the Google Sign-In process
      await GoogleSignIn().signOut();

      // Initiate Google Log-In process
      final GoogleSignInAccount? googleUser = await GoogleSignIn(scopes: [
        "https://www.googleapis.com/auth/userinfo.profile",
        "https://www.googleapis.com/auth/userinfo.email"
      ]).signIn();
      if (googleUser == null) {
        return "Google Log-In was canceled. Please try again.";
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      // Get the credentials from Google
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // Log in to Firebase with the Google credentials
      UserCredential userCredential =
          await auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        return "Failed to log in with Google. Please try again.";
      }

      // Check if the user exists in the users collection and has the service_provider role
      DocumentSnapshot userDoc =
          await firestore.collection("users").doc(user.uid).get();
      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        // Check for the service_provider role
        List<dynamic> roles = userData['roles'] ?? [];
        if (roles.contains('service_provider')) {
          return "Service Provider";
        } else {
          return "You are not registered as a service provider. Please use the appropriate account.";
        }
      } else {
        return "No account found. Please register as a service provider.";
      }
    } on FirebaseAuthException catch (e) {
      return e.message ??
          "A problem occurred during Google Log-In. Please try again.";
    } catch (e) {
      return "An unexpected error occurred. Please try again later.";
    }
  }
}
