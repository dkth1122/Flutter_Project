import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_flutter/chat/chat.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> messageStream = _fs
        .collection("chat_rooms")
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: "yyn1234")
        .snapshots();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('채팅 목록'),
        ),
        body: MessageListWidget(messageStream: messageStream),
      ),
    );
  }
}

class MessageListWidget extends StatelessWidget {
  final Stream<QuerySnapshot> messageStream;

  MessageListWidget({required this.messageStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: messageStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {

        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snap.data!.docs.map((DocumentSnapshot doc) {
            Map<String, dynamic> messageData = doc.data() as Map<String, dynamic>;

            String messageText = messageData['text'];
            String sender = messageData['user'];

            return ListTile(
              title: Text(sender),
              subtitle: Text(messageText),
            );
          }).toList(),
        );
      },
    );
  }
}
