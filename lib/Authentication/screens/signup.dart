import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../Widgets/button.dart';
import '../Widgets/snackBar.dart';
import '../Widgets/text_field.dart';
import '../services/authentication.dart';
import '../widgets/carImage.dart';
import '../widgets/googleButton.dart';
import '../widgets/or.dart';
import '../widgets/texfieldPassword.dart';
import '../widgets/validator.dart';
import 'homeScreen.dart';
import 'login.dart';
import 'package:autocare_automotiveshops/Authentication/screens/verifyEmail.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, this.child});

  final Widget? child;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
  }

  void signupUser() async {
    setState(() {
      isLoading = true;
    });

    // Check if passwords match
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        isLoading = false;
      });
      Utils.showSnackBar("Passwords do not match.");
      return;
    }

    String res = await AuthenticationMethod().signupServiceProvider(
      email: emailController.text,
      password: passwordController.text,
      name: nameController.text,
    );

    if (res == "SUCCESS") {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.sendEmailVerification();
          setState(() {
            isLoading = false;
          });

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const VerifyEmailScreen(),
            ),
          );
        } else {
          setState(() {
            isLoading = false;
          });
          Utils.showSnackBar("Failed to retrieve user.");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        Utils.showSnackBar(e.toString());
      }
    } else {
      setState(() {
        isLoading = false;
      });
      Utils.showSnackBar(res);
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    String res = await AuthenticationMethod().signInWithGoogle();

    if (res == "SUCCESS") {
      setState(() {
        isLoading = false;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      Utils.showSnackBar(res);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 40),
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "Auto",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 50,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: "Care+",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: const Duration(seconds: 3)),
              ),

              // Sign Up Image
              const CarImageWidget(
                      imagePath: 'lib/Authentication/assets/images/car.png')
                  .animate()
                  .fadeIn(duration: const Duration(seconds: 1)),
              // Sign Up Form
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: <Widget>[
                    TextFieldInput(
                      icon: Icons.person,
                      textEditingController: nameController,
                      hintText: 'Enter your Name',
                      textInputType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    TextFieldInput(
                      icon: Icons.email,
                      textEditingController: emailController,
                      hintText: 'Enter your Email',
                      textInputType: TextInputType.text,
                      validator: (value) {
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email';
                        } else if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    TextFieldPassword(
                      icon: Icons.lock,
                      textEditingController: passwordController,
                      hintText: 'Enter your Password',
                      textInputType: TextInputType.text,
                      validator: passwordValidator,
                      isPass: true,
                    ),
                    TextFieldPassword(
                      icon: Icons.lock,
                      textEditingController: confirmPasswordController,
                      hintText: 'Confirm your Password',
                      textInputType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        return null;
                      },
                      isPass: true,
                    ),

                    // Sign Up Button
                    MyButtons(onTap: signupUser, text: "Sign Up"),

                    // Sign Up OR
                    const Or(),

                    // Sign Up with Google
                    SizedBox(height: size.height * 0.01),
                    GoogleButton(
                      onTap: signInWithGoogle,
                      hintText: 'Sign Up with Google',
                    ),

                    // Already have an account? Log In
                    const SizedBox(height: 30),
                    TextButton(
                      onPressed: () {
                        // Handle navigation to login screen
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: const TextStyle(color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Log In',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigate to LoginScreen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().slide(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  begin: const Offset(0, 1),
                  end: const Offset(0, 0)),
            ],
          ),
        ),
      ),
    );
  }
}
