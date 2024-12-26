import 'package:autocare_automotiveshops/Authentication/services/authentication_signout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}

void main() {
  late AuthenticationMethodSignOut authMethod;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();

    authMethod = AuthenticationMethodSignOut(
      auth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('signOut', () {
    test('should sign out user successfully', () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async => Future.value());
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async => Future.value());

      await authMethod.signOut();

      verify(mockFirebaseAuth.signOut()).called(1);
      verify(mockGoogleSignIn.signOut()).called(1);
    });

    test('should handle sign out failure', () async {

      when(mockFirebaseAuth.signOut()).thenThrow(Exception('Sign out error'));
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async => Future.value());


      await authMethod.signOut();

      verify(mockFirebaseAuth.signOut()).called(1);
      verify(mockGoogleSignIn.signOut()).called(0);
    });

    test('should handle case when no user is signed in', () async {

      await authMethod.signOut();

      verify(mockFirebaseAuth.signOut()).called(0);
      verify(mockGoogleSignIn.signOut()).called(0);
    });
  });
}
