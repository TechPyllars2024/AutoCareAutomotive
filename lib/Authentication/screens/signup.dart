import 'package:autocare_automotiveshops/Authentication/screens/onboarding.dart';
import 'package:autocare_automotiveshops/Authentication/services/authentication_signin.dart';
import 'package:autocare_automotiveshops/Booking%20Mangement/screens/automotive_booking.dart';
import 'package:autocare_automotiveshops/Navigation%20Bar/navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../Widgets/button.dart';
import '../Widgets/snackBar.dart';
import '../Widgets/text_field.dart';
import '../widgets/carImage.dart';
import '../widgets/googleButton.dart';
import '../widgets/or.dart';
import '../widgets/texfieldPassword.dart';
import '../widgets/validator.dart';
import 'login.dart';
import 'package:autocare_automotiveshops/Authentication/screens/verifyEmail.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, this.child});
  final Widget? child;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isLoadingSignup = false;
  bool isLoadingGoogle = false;

  @override
  void dispose() {
    super.dispose();

    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  void signupUser() async {
    final passwordError = passwordValidator(passwordController.text);
    String? confirmPasswordError;

    setState(() {
      isLoadingSignup = true;
    });

    if (passwordError != null || confirmPasswordError != null) {
      setState(() {
        isLoadingSignup = false;
      });
      Utils.showSnackBar("Please enter a valid password");
      return;
    }


    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        isLoadingSignup = false;
      });
      Utils.showSnackBar("Passwords do not match.");
      return;
    }

    String res = await AuthenticationMethodSignIn().signupServiceProvider(
      email: emailController.text,
      password: passwordController.text,
    );

    if (res == "SUCCESS") {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.sendEmailVerification();
          setState(() {
            isLoadingSignup = false;
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const VerifyEmailScreen(),
            ),
          );
        } else {
          setState(() {
            isLoadingSignup = false;
          });
          Utils.showSnackBar("Failed to retrieve user.");
        }
      } catch (e) {
        setState(() {
          isLoadingSignup = false;
        });
        Utils.showSnackBar(e.toString());
      }
    } else {
      setState(() {
        isLoadingSignup = false;
      });
      Utils.showSnackBar(res);
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      isLoadingGoogle = true;
    });

    String res = await AuthenticationMethodSignIn().signInWithGoogle();
    setState(() {
      isLoadingGoogle = false;
    });

    if (res == "SUCCESS") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const Onboarding(),
        ),
      );
    } else {
      Utils.showSnackBar(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(

      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Column(

        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[

          const CarImageWidget(
            imagePath: 'lib/Authentication/assets/images/repair2.jpg',
          ).animate().fadeIn(duration: const Duration(seconds: 2)),


          Expanded(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[


                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: RichText(
                          text:  TextSpan(
                            children: [
                              const TextSpan(
                                text: "Auto",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 30,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: "Care+",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 30,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: const Duration(seconds: 3)),
                      ),

                      TextFieldInput(
                        icon: Icons.email,
                        textEditingController: emailController,
                        hintText: 'Email',
                        textInputType: TextInputType.text,
                        validator: (value) {

                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');


                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }


                          else if (!emailRegex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }


                          return null;
                        },
                      ),
                      TextFieldPassword(
                        icon: Icons.lock,
                        textEditingController: passwordController,
                        hintText: 'Password',
                        textInputType: TextInputType.text,
                        validator: passwordValidator,
                        isPass: true,
                      ),
                      TextFieldPassword(
                        icon: Icons.lock,
                        textEditingController: confirmPasswordController,
                        hintText: 'Confirm Password',
                        textInputType: TextInputType.text,
                        validator: (value) {

                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }


                          final passwordError = passwordValidator(passwordController.text);
                          if (passwordError != null) {
                            return 'The password does not meet the required criteria';
                          }


                          if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }


                          return null;
                        },
                        isPass: true,
                      ),


                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: MyButtons(
                          onTap: signupUser,
                          text: "Sign Up",
                          isLoading: isLoadingSignup,
                        ),
                      ),


                      SizedBox(height: size.height * 0.03),
                      const Or(),


                      SizedBox(height: size.height * 0.03),
                      GoogleButton(
                        onTap: signInWithGoogle,
                        hintText: 'Sign Up with Google',
                      ),


                      SizedBox(height: size.height * 0.06),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: 'Already have an account? ',
                            style: const TextStyle(color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Log In',
                                style: TextStyle(
                                  color: Colors.orange.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const LoginScreen(),
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 25)
                    ],
                  ),
                ),
              ),
            ).animate().slide(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              begin: const Offset(0, 1),
              end: const Offset(0, 0),
            ),
          ),
        ],
      ),
    );
  }
}
