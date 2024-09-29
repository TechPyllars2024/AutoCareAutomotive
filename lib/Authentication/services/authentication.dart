import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Widgets/snackBar.dart';
import '../models/service_provider.dart';

class AuthenticationMethod {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // SIGN UP with Email and Password for Service Providers
  Future<String> signupServiceProvider({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return "Please fill in all the required fields.";
    }
    try {
      // Check if the user already exists with a conflicting role
      DocumentSnapshot existingUserDoc =
      await firestore.collection("users").doc(email).get();

      if (existingUserDoc.exists) {
        UserModel existingUser =
        UserModel.fromMap(existingUserDoc.data() as Map<String, dynamic>);
        if (existingUser.roles.contains('car_owner')) {
          return "It looks like you already have a car owner account. Please use a different email or log in.";
        }
      }

      // Register the user with email and password
      UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create the ServiceProviderModel
      UserModel newUser = UserModel(
        uid: credential.user!.uid,
        email: email,
        roles: ['service_provider'],
      );

      // Add the user to Firestore in the users collection
      await firestore.collection("users").doc(newUser.uid).set(newUser.toMap());

      return 'SUCCESS';
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return "The email address is already in use by another account. Please use a different email.";
        case 'weak-password':
          return "The password is too weak. Please choose a stronger password.";
        case 'invalid-email':
          return "The email address is not valid. Please check and try again.";
        default:
          return e.message ?? "We encountered an error during registration. Please try again.";
      }
    } catch (e) {
      return "Something went wrong. Please try again later.";
    }
  }

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
      await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return "SUCCESS";
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

  // SIGN IN/LOG IN WITH GOOGLE
  Future<String> signInWithGoogle() async {
    try {
      // Initiate Google Sign-In process
      final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: [
            "https://www.googleapis.com/auth/userinfo.profile",
            "https://www.googleapis.com/auth/userinfo.email"
          ]
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return "Google Sign-In was canceled. Please try again.";
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Get the credentials from Google
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credentials
      UserCredential userCredential =
          await auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        return "Failed to sign in with Google. Please try again.";
      }

      // Check if the user already exists as a car owner
      QuerySnapshot existingCarOwner = await firestore
          .collection("users")
          .where('email', isEqualTo: user.email)
          .where('roles', arrayContains: 'car_owner')
          .get();

      if (existingCarOwner.docs.isNotEmpty) {
        // Sign out the user from Google Sign-In
        await googleSignIn.signOut();
        return "You already have an account as a car owner. Please sign in with a different account.";
      }

      // Check if the user already exists as a service provider
      QuerySnapshot existingServiceProvider = await firestore
          .collection("users")
          .where('email', isEqualTo: user.email)
          .where('roles', arrayContains: 'service_provider')
          .get();

      if (existingServiceProvider.docs.isNotEmpty) {
        // Sign out the user from Google Sign-In
        await googleSignIn.signOut();
        return "You already have an account as a service provider. Please sign in with a different account.";
      }

      // Create the ServiceProviderModel and store in Firestore
      UserModel newUser = UserModel(
        uid: user.uid,
        email: user.email ?? "No Email",
        roles: ['service_provider'],
      );

      await firestore.collection("users").doc(newUser.uid).set(newUser.toMap());

      return 'SUCCESS';
    } on FirebaseAuthException catch (e) {
      return e.message ?? "A problem occurred during Google Sign-In. Please try again.";
    } catch (e) {
      return "An unexpected error occurred. Please try again later.";
    }
  }

  // Handles Google Log-In and checks user role
  Future<String> logInWithGoogle() async {
    try {
      // Ensure the user is signed out before starting the Google Sign-In process
      await GoogleSignIn().signOut();

      // Initiate Google Log-In process
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
          scopes: [
            "https://www.googleapis.com/auth/userinfo.profile",
            "https://www.googleapis.com/auth/userinfo.email"
          ]
      ).signIn();
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
      return e.message ?? "A problem occurred during Google Log-In. Please try again.";
    } catch (e) {
      return "An unexpected error occurred. Please try again later.";
    }
  }
}
