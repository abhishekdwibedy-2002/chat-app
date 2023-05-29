import 'dart:ui' as ui;
import 'package:chat_app/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/screens/register_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

final firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final formKey = GlobalKey<FormState>();
  var isLogin = true;
  var enteredEmail = '';
  var enteredPassword = '';
  bool isLoading = false;
  void submit() async {
    final isValid = formKey.currentState!.validate();
    if (!isValid) {
      setState(() {
        isLoading = true;
      });
    }
    formKey.currentState!.save();
    try {
      if (isLogin) {
        await firebase.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);
        if (context.mounted) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ChatScreen()));
        }
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication Failed!')));
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onPrimary),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 80,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Title(
                        color: Theme.of(context).colorScheme.onPrimary,
                        child: Text(
                          'WhatsUp!',
                          style: TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader = ui.Gradient.linear(
                                const Offset(140, 20),
                                const Offset(290, 20),
                                [
                                  Colors.black87,
                                  Colors.deepOrangeAccent,
                                ],
                              ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Signing to know who\'s writing what',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black.withOpacity(0.4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 35,
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 20, top: 20, right: 20, bottom: 20),
                        width: 200,
                        child: Image.asset('assets/images/chat.png'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Card(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: 'Email',
                                        prefixIcon: Icon(Icons.email),
                                        prefixIconColor:
                                            Colors.deepOrangeAccent),
                                    autocorrect: false,
                                    keyboardType: TextInputType.emailAddress,
                                    textCapitalization: TextCapitalization.none,
                                    onChanged: (value) {
                                      enteredEmail = value;
                                    },
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty ||
                                          !value.contains('@')) {
                                        return 'Enter a valid E-Mail Address';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: 'Password',
                                        prefixIcon: Icon(Icons.lock),
                                        prefixIconColor:
                                            Colors.deepOrangeAccent),
                                    obscureText: true,
                                    onChanged: (value) {
                                      enteredPassword = value;
                                    },
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().length < 6) {
                                        return 'Password must be 6 characters long.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 100,
                      ),
                      SizedBox(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                shadowColor: Colors.deepOrangeAccent,
                                backgroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                foregroundColor: Colors.deepOrangeAccent,
                                elevation: 1),
                            onPressed: submit,
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text.rich(
                        TextSpan(
                          text: 'Don\'t have an account? ',
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                                text: 'Register here',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.deepOrangeAccent,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RegisterScreen(),
                                      ),
                                    );
                                  }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
