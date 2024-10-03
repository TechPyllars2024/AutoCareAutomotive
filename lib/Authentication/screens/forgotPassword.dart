import 'dart:ui';

import 'package:autocare_automotiveshops/Authentication/services/authentication_reset_password.dart';
import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import '../Widgets/button.dart';
import 'login.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    if (formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      String res = await AuthenticationMethodResetPassword().resetPassword(
        email: emailController.text,
      );

      setState(() {
        isLoading = false;
      });

      if (res == "SUCCESS") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset email sent")),
        );
        Navigator.of(context).pop(); // Navigate back to the previous screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Reset Password"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'lib/Authentication/assets/images/forgotpassword.png',
                width: 300,
                height: 300,
              ).animate().fadeIn(duration: const Duration(seconds: 1)),

              const SizedBox(height: 80),

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter Your Email Below',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              TextFormField(
                controller: emailController,
                cursorColor: Colors.black,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "Please enter a valid email address";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : MyButtons(
                onTap: resetPassword,
                text: "Reset Password",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
