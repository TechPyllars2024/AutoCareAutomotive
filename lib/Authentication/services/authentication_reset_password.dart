import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationMethodResetPassword {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final user = FirebaseAuth.instance.currentUser;

  // RESET PASSWORD
  Future<String> resetPassword({
    required String email,
  }) async {
    if (email.isEmpty) {
      return "Please enter your email address.";
    }

    try {
      // Query Firestore to check if the email exists in the "users" collection
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // Check if any documents were returned
      if (querySnapshot.docs.isEmpty) {
        return "No account found with this email. Please check or sign up.";
      }

      // If email exists, proceed to send the password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return "A reset link has been sent.";
    } on FirebaseAuthException catch (e) {
      // Handle specific errors
      switch (e.code) {
        case 'invalid-email':
          return "The email address you entered is not properly formatted. Please check it.";
        case 'user-not-found':
          return "There is no account registered with this email.";
        case 'too-many-requests':
          return "You've made too many requests. Please wait for a moment and try again.";
        default:
          return e.message ?? "An error occurred. Please try again.";
      }
    } catch (e) {
      return "Something went wrong. Please try again later.";
    }
  }
}
