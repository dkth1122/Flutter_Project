import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatApp extends StatefulWidget {

  var roomId;

  ChatApp({required this.roomId});

  @override
  State createState() => ChatAppState();
}

class ChatAppState extends State<ChatApp> {
  final CollectionReference chatCollection =
  FirebaseFirestore.instance.collection('chat');
  TextEditingController messageController = TextEditingController();
  String roomId = "user1_user2";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Chat App'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: chatCollection
                    .doc(roomId)
                    .collection('message')
                    .orderBy('sendTime')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final messages = snapshot.data?.docs;
                  List<Widget> messageWidgets = [];
                  for (var message in messages!) {
                    final messageText = message['text'];
                    final messageSender = message['sender'];
                    final messageWidget = MessageWidget(
                      sender: messageSender,
                      text: messageText,
                    );
                    messageWidgets.add(messageWidget);
                  }
                  return ListView(
                    children: messageWidgets,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: 'Enter a message...',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      sendMessage(roomId, 'user1', messageController.text);
                      messageController.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage(String roomId, String sender, String text) {
    chatCollection.doc(roomId).collection('message').add({
      'sendTime': DateTime.now(),
      'sender': sender,
      'text': text,
    });
  }
}

class MessageWidget extends StatelessWidget {
  final String sender;
  final String text;

  MessageWidget({required this.sender, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$sender: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(text),
        ],
      ),
    );
  }
}
