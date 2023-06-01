import 'package:chat_app/widgets/chat_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatLook extends StatefulWidget {
  const ChatLook({super.key});

  @override
  State<ChatLook> createState() => _ChatLookState();
}

class _ChatLookState extends State<ChatLook> {
  final authenticUser = FirebaseAuth.instance.currentUser!;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('time', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No Messages Found !'),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something Went Wrong...'),
          );
        }
        final loadedData = snapshot.data!.docs;
        return ListView.builder(
          padding:
              const EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 40),
          reverse: true,
          itemCount: loadedData.length,
          itemBuilder: (context, index) {
            final chatMessage = loadedData[index].data();
            final nextMessage = index + 1 < loadedData.length
                ? loadedData[index + 1].data()
                : null;
            final currentMessageUserId = chatMessage['userId'];
            final nextMessageUserId =
                nextMessage != null ? nextMessage['userId'] : null;
            final nextuserIsSame = nextMessageUserId == currentMessageUserId;
            if (nextuserIsSame) {
              return ChatView.next(
                  message: chatMessage['text'],
                  isMe: authenticUser.uid == currentMessageUserId);
            } else {
              return ChatView.first(
                userImage: chatMessage['imgUrl'],
                username: chatMessage['username'],
                message: chatMessage['text'],
                isMe: authenticUser.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
