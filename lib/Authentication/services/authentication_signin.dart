import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/service_provider_model.dart';

class AuthenticationMethodSignIn{
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final user = FirebaseAuth.instance.currentUser;

  // SIGN UP with Email and Password for Service Providers
  Future<String> signupServiceProvider({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return "Please fill in all the required fields.";
    }
    try {
      // Check if the user already exists as a service provider
      QuerySnapshot existingServiceProvider = await firestore
          .collection("users")
          .where('email', isEqualTo: user?.email)
          .where('roles', arrayContains: 'service_provider')
          .get();

      if (existingServiceProvider.docs.isNotEmpty) {
        // Sign out the user from Google Sign-In
        await googleSignIn.signOut();
        return "An account already exists for you as a service provider. Please use a different Google account.";
      }

      // Check if the user already exists as a car owner
      QuerySnapshot existingCarOwner = await firestore
          .collection("users")
          .where('email', isEqualTo: user?.email)
          .where('roles', arrayContains: 'car_owner')
          .get();

      if (existingCarOwner.docs.isNotEmpty) {
        // Sign out the user from Google Sign-In
        await googleSignIn.signOut();
        return "You already have a car owner account. Please log in using your existing account.";
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
}