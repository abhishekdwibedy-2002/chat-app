import 'package:chat_app/screens/auth_screen.dart';
import 'package:chat_app/widgets/user_imageselect.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

final firebase = FirebaseAuth.instance;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final form = GlobalKey<FormState>();
  final isSignIn = true;
  var enterName = '';
  var enterEmail = '';
  var enterPass = '';
  bool isLoading = false;
  File? selectImage;

  void submit() async {
    final isValid = form.currentState!.validate();
    if (!isValid || !isSignIn || selectImage == null) {
      setState(() {
        isLoading = true;
      });
    }
    form.currentState!.save();
    if (isSignIn) {
      try {
        final userCredential = await firebase.createUserWithEmailAndPassword(
            email: enterEmail, password: enterPass);
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('userImages')
            .child('${userCredential.user!.uid}jpg');
        await storageRef.putFile(selectImage!);
        final imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': enterName,
          'email': enterEmail,
          'password': enterPass,
          'imageurl': imageUrl,
          'userId': userCredential.user!.uid,
        });
        if (context.mounted) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AuthScreen()));
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 40,
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
                        'Create your account now to Chat and Explore',
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
                        height: 5,
                      ),
                      Card(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Form(
                              key: form,
                              child: Column(
                                children: [
                                  if (isSignIn)
                                    UserImagePicker(
                                      onPickImage: (pickedImage) {
                                        selectImage = pickedImage;
                                      },
                                    ),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                        labelText: 'Full Name',
                                        prefixIcon: Icon(Icons.person),
                                        prefixIconColor:
                                            Colors.deepOrangeAccent),
                                    autocorrect: true,
                                    keyboardType: TextInputType.name,
                                    onChanged: (value) {
                                      enterName = value;
                                    },
                                    validator: (value) {
                                      if (value!.trim().isEmpty) {
                                        return 'Name Cannot be Empty.';
                                      }
                                      return null;
                                    },
                                  ),
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
                                      enterEmail = value;
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
                                      enterPass = value;
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
                                    height: 0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
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
                              'Sign In',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            )),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text.rich(
                        TextSpan(
                          text: 'Already have an account? ',
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                                text: 'Login here',
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.deepOrangeAccent,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AuthScreen(),
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
