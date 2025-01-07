import 'package:autocare_automotiveshops/Authentication/screens/onboarding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../Widgets/snackBar.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key, this.child});

  final Widget? child;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  Timer? timer;
  bool canResendEmail = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      isEmailVerified = user.emailVerified;

      if (!isEmailVerified) {
        // Start periodic check for email verification but don't resend automatically
        timer = Timer.periodic(
          const Duration(seconds: 3),
          (_) => checkEmailVerified(),
        );
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      setState(() {
        isEmailVerified = user.emailVerified;
      });

      if (isEmailVerified) timer?.cancel();
    }
  }

  Future<void> sendVerificationEmail() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && canResendEmail) {
        await user.sendEmailVerification();

        setState(() {
          canResendEmail = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent. Please check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(seconds: 30));

        setState(() {
          canResendEmail = true;
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'too-many-requests') {
        Utils.showSnackBar("Too many requests. Please try again later.");
        setState(() {
          canResendEmail = false;
        });

        await Future.delayed(const Duration(seconds: 60));

        setState(() {
          canResendEmail = true;
        });
      } else {
        Utils.showSnackBar(e.message ?? "An error occurred.");
      }
    } catch (e) {
      Utils.showSnackBar("An unexpected error occurred.");
    }

    setState(() {
      isLoading = false; // Hide loader
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: isEmailVerified
          ? const Onboarding()
          : Scaffold(
              backgroundColor: Colors.grey.shade100,
              appBar: AppBar(
                backgroundColor: Colors.grey.shade100,
                automaticallyImplyLeading: false,
                title: const Text(
                  'Verify Email',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/Authentication/assets/images/verifyemail.png',
                      width: 200,
                      height: 200,
                    ),
                    const SizedBox(height: 50),
                    const Column(
                      children: [
                        Text(
                          'A Verification Email has been Sent!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Kindly check your inbox and spam folder.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.normal,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 70),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            minimumSize: const Size(400, 45),
                            backgroundColor: Colors.deepOrange.shade700,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          icon: const Icon(Icons.email,
                              size: 20, color: Colors.white),
                          label: const Text(
                            'Resend Email',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          onPressed: canResendEmail && !isLoading
                              ? sendVerificationEmail
                              : null,
                        ),
                        if (isLoading)
                          Positioned(
                            child: Container(
                              width: 350,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.deepOrange.shade700,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
