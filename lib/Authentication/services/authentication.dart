import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Widgets/snackBar.dart';

class AuthenticationMethod {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // SIGN UP with Email and Password
  Future<String> signupUser({
    required String name,
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      return "Please provide all the fields";
    }
    try {
      // Register the user with email and password
      UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add the user to Firestore database
      await firestore.collection("service providers").doc(credential.user!.uid).set({
        'name': name,
        'uid': credential.user!.uid,
        'email': email,
      });
      return 'SUCCESS';
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An error occurred";
    } catch (e) {
      return "An unexpected error occurred";
    }
  }

  // LOG IN with Email and Password
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return "Please provide all the fields";
    }

    try {
      // Logging in user with email and password
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return "SUCCESS";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An error occurred";
    } catch (e) {
      return "An unexpected error occurred";
    }
  }

  // SIGN OUT
  Future<void> signOut() async {
    try {
      await auth.signOut();
      await googleSignIn.signOut();
    } catch (e) {
      Utils.showSnackBar("An error occurred while signing out");
    }
  }

  // RESET PASSWORD
  // RESET PASSWORD
  Future<String> resetPassword({
    required String email,
  }) async {
    if (email.isEmpty) {
      return "Please provide an email";
    }

    try {
      // Try sending the reset password email
      await auth.sendPasswordResetEmail(email: email);
      return "SUCCESS";
    } on FirebaseAuthException catch (e) {
      // Handle specific errors
      if (e.code == 'user-not-found') {
        return "No account found with that email";
      } else {
        return e.message ?? "An error occurred";
      }
    } catch (e) {
      return "An unexpected error occurred";
    }
  }



  // SIGN IN/LOG IN WITH GOOGLE
  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return "Google sign-in aborted";
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await auth.signInWithCredential(credential);

      DocumentSnapshot userDoc = await firestore.collection("service providers").doc(userCredential.user!.uid).get();

      if (!userDoc.exists) {
        await firestore.collection("users").doc(userCredential.user!.uid).set({
          'name': userCredential.user!.displayName ?? "No Name",
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email ?? "No Email",
        });
      }

      return "SUCCESS";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An error occurred";
    } catch (e) {
      return "An unexpected error occurred";
    }
  }
}
