import 'package:flutter/material.dart';

class ChatLook extends StatefulWidget {
  const ChatLook({super.key});

  @override
  State<ChatLook> createState() => _ChatLookState();
}

class _ChatLookState extends State<ChatLook> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No Messages Found !'),
    );
  }
}
