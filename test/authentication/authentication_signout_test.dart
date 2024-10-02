import 'package:autocare_automotiveshops/Authentication/services/authentication_signout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';

// Create Mock Classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}

void main() {
  late AuthenticationMethodSignOut authMethod;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();

    // Create an instance of AuthenticationMethodSignOut with mocked dependencies
    authMethod = AuthenticationMethodSignOut(
      auth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('signOut', () {
    test('should sign out user successfully', () async {
      // Arrange: Set up the mocks to return successfully
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async => Future.value());
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async => Future.value());

      // Act: Call the signOut method
      await authMethod.signOut();

      // Assert: Verify that signOut was called
      verify(mockFirebaseAuth.signOut()).called(1);
      verify(mockGoogleSignIn.signOut()).called(1);
    });

    test('should handle sign out failure', () async {
      // Arrange: Set up the mocks to throw an exception
      when(mockFirebaseAuth.signOut()).thenThrow(Exception('Sign out error'));
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async => Future.value());

      // Act: Call the signOut method
      await authMethod.signOut();

      // Assert: Verify that signOut was called for FirebaseAuth
      verify(mockFirebaseAuth.signOut()).called(1);
      verify(mockGoogleSignIn.signOut()).called(0); // Should not reach this point
      // You can verify that your snackbar method was called as well, if applicable
    });

    test('should handle case when no user is signed in', () async {
      // Arrange: Do not set up any current user, meaning it's null

      // Act: Call the signOut method
      await authMethod.signOut();

      // Assert: Verify that signOut is called
      verify(mockFirebaseAuth.signOut()).called(0); // Should not call signOut if no user
      verify(mockGoogleSignIn.signOut()).called(0); // Should not call signOut if no user
    });
  });
}
