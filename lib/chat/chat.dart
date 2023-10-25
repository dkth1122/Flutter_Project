import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Chat());
}

class Chat extends StatefulWidget {
  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  String newMessage = "";
  late TextEditingController messageController;

  @override
  void initState() {
    super.initState();
    messageController = TextEditingController();
  }

  Widget _chatList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("chat").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snap.hasError) {
          return Text('Error: ${snap.error}');
        }

        if (snap.data != null) {
          return ListView(
            reverse: true, // 채팅 내용을 역순으로 표시
            children: snap.data!.docs.reversed.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return ChatMessage(
                text: data['text'],
                sendTime: data['sendTime'].toDate(),
              );
            }).toList(),
          );
        } else {
          return Text('No data available.');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Chat App'),
        ),
        body: Column(
          children: [
            Expanded(
              child: _chatList(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (text) {
                        setState(() {
                          newMessage = text;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: '메시지 입력',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      handleOnSubmit();
                    },
                    child: Text('전송'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleOnSubmit() {
    if (newMessage.trim().isNotEmpty) {
      FirebaseFirestore.instance.collection('chat').add({
        'text': newMessage.trim(),
        'sendTime': FieldValue.serverTimestamp(),
        'user': 'User', // Change to current user's display name
      });

      messageController.clear();
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final DateTime sendTime;

  ChatMessage({
    required this.text,
    required this.sendTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // 채팅 내용을 오른쪽에 표시
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.only(right: 16.0), // 채팅 내용과 오른쪽 경계 간격 설정
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.blue, // 채팅 메시지 배경색
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  text,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Text(
                '${sendTime.toLocal().toString()}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
