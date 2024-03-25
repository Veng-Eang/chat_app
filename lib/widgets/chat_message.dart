import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    print('email : ${authenticatedUser.email}');
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy(
              'createAt',
              descending: true,
            )
            .snapshots(),
        builder: (ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No message found.'),
            );
          }
          if (chatSnapshot.hasError) {
            return const Center(
              child: Text('Something went wrong....'),
            );
          }
          final loadMessages = chatSnapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 40,
              left: 13,
              right: 13,
            ),
            reverse: true,
            itemCount: loadMessages.length,
            itemBuilder: (ctx, index) {
              final chatMessage = loadMessages[index].data();
              final nextChatMessage = index + 1 < loadMessages.length
                  ? loadMessages[index + 1].data()
                  : null;
              final currentMessageUserId = chatMessage['userId'];
              print('current user id ${chatMessage['text']}');
              print('load messege count: ${loadMessages.length}');
              final nextMessageUserId =
                  nextChatMessage != null ? nextChatMessage['userId'] : null;
              print('next message user id ${currentMessageUserId}');
              final nextUserIsSame = nextMessageUserId == currentMessageUserId;
              if (nextUserIsSame) {
                return MessageBubble.next(
                  message: chatMessage['text'],
                  isMe: authenticatedUser.uid == currentMessageUserId,
                );
              } else {
                return MessageBubble.first(
                  userImage: chatMessage['userImage'],
                  username: chatMessage['username'],
                  message: chatMessage['text'],
                  isMe: authenticatedUser.uid == currentMessageUserId,
                );
              }
            },
          );
        });
  }
}
