import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Widgets/snackBar.dart';
import '../models/service_provider_model.dart';

class AuthenticationMethod {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  // SIGN UP with Email and Password for Service Providers
  Future<String> signupServiceProvider({
    required String name,
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      return "Please provide all the fields";
    }
    try {
      // Check if the user already exists with a conflicting role
      QuerySnapshot existingUser = await firestore
          .collection("users")
          .where('email', isEqualTo: email)
          .where('roles', arrayContains: 'car_owner')
          .get();

      if (existingUser.docs.isNotEmpty) {
        return "You already have an account as a car owner";
      }

      // Check if the user already exists as a service provider
      QuerySnapshot existingServiceProvider = await firestore
          .collection("users")
          .where('email', isEqualTo: email)
          .where('roles', arrayContains: 'service_provider')
          .get();

      if (existingServiceProvider.docs.isNotEmpty) {
        return "You already have an account as a service provider";
      }

      // Register the user with email and password
      UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create the ServiceProviderModel
      UserModel newUser = UserModel(
        uid: credential.user!.uid,
        name: name,
        email: email,
        roles: ['service_provider'],
      );

      // Add the user to Firestore in the users collection
      await firestore.collection("users").doc(newUser.uid).set(newUser.toMap());

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
  Future<String> resetPassword({
    required String email,
  }) async {
    if (email.isEmpty) {
      return "Please provide an email";
    }

    try {
      // Query Firestore to check if the email exists in the "users" collection
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1) // Limit to 1 result for efficiency
          .get();

      // Check if any documents were returned
      if (querySnapshot.docs.isEmpty) {
        return "No account found with that email";
      }

      // If email exists, proceed to send the password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      return "A reset link has been sent.";
    } on FirebaseAuthException catch (e) {
      // Handle specific errors
      if (e.code == 'invalid-email') {
        return "The email address is badly formatted";
      } else if (e.code == 'too-many-requests') {
        return "Too many requests, please try again later";
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
      // Initiate Google Sign-In process
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return "Google Sign-In aborted";
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
        return "Google Sign-In failed";
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
        name: user.displayName ?? "No Name",
        email: user.email ?? "No Email",
        roles: ['service_provider'],
      );

      await firestore.collection("users").doc(newUser.uid).set(newUser.toMap());

      return 'SUCCESS';
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An error occurred";
    } catch (e) {
      return "An unexpected error occurred";
    }
  }

  // Handles Google Log-In and checks user role
  Future<String> logInWithGoogle() async {
    try {
      // Ensure the user is signed out before starting the Google Sign-In process
      await GoogleSignIn().signOut();

      // Initiate Google Log-In process
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return "Google Log-In aborted";
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
        return "Google Log-In failed";
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
          return "You are not registered as a service provider";
        }
      } else {
        return "User does not exist. Please register first.";
      }
    } on FirebaseAuthException catch (e) {
      return e.message ?? "An error occurred";
    } catch (e) {
      return "An unexpected error occurred";
    }
  }
}
