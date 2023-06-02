import 'package:chat_app/screens/auth_screen.dart';
import 'package:chat_app/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final authenticUser = FirebaseAuth.instance.currentUser!;
  String currentUserName = '';
  String currentUserEmail = '';
  String imageProfile = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profile Screen',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('userId', isEqualTo: authenticUser.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Error fetching user data'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final userData = snapshot.data!.docs;
            // final userName = userData['username'];
            // final userEmail = userData['email'];
            return ListView.builder(
              itemCount: userData.length,
              itemBuilder: (context, index) {
                final userdata = userData[index].data();
                currentUserName = userdata['username'];
                currentUserEmail = userdata['email'];
                imageProfile = userdata['imageurl'];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(imageProfile),
                        radius: 120.0,
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        currentUserName,
                        textScaleFactor: 1,
                        style: const TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        currentUserEmail,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Divider(
                        height: 10,
                      ),
                      ListTile(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: ((context) => const ChatScreen())));
                        },
                        selectedColor: Colors.black,
                        selected: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        leading: const Icon(Icons.home),
                        title: const Text('Home'),
                      ),
                      ListTile(
                        onTap: () {},
                        selectedColor: Colors.black,
                        selected: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        leading: const Icon(Icons.person),
                        title: const Text('Profile'),
                      ),
                      ListTile(
                        onTap: () async {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('LogOut'),
                                  content: const Text(
                                      'Are you sure you want to LogOut?'),
                                  actions: [
                                    IconButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      icon: const Icon(Icons.cancel),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        FirebaseAuth.instance.signOut();
                                        Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: ((context) =>
                                                    const AuthScreen())));
                                      },
                                      icon: const Icon(Icons.done),
                                    ),
                                  ],
                                );
                              });
                        },
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        leading: const Icon(Icons.exit_to_app),
                        title: const Text(
                          'LogOut',
                          style: TextStyle(color: Colors.black87),
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          }),
    );
  }
}
