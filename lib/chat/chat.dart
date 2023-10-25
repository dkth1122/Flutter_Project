import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_flutter/firebase_options.dart';
import 'package:uuid/uuid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

// 사용자 A와 사용자 B의 UUID 생성
  final Uuid uuid = Uuid();
  final String userAId = uuid.v4();
  final String userBId = uuid.v4();

// 채팅방 문서 ID => 방 이름 생성
  final String chatRoomId = 'chat_room_${userAId}_${userBId}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat App'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ChatMessages(chatRoomId: chatRoomId),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: '메시지 입력'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _handleOnSubmit();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleOnSubmit() {
    final String text = _messageController.text;
    if (text.isNotEmpty) {
      // 채팅방 문서의 컬렉션 "messages"에 메시지 추가
      _firestore.collection('chat_rooms/$chatRoomId/messages').add({
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }
}

class ChatMessages extends StatelessWidget {
  final String chatRoomId;

  ChatMessages({
    required this.chatRoomId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms/$chatRoomId/messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final messages = snapshot.data!.docs;

        List<Widget> messageWidgets = [];
        for (var message in messages) {
          final messageText = message['text'];
          final messageTimestamp = message['timestamp'];

          final messageWidget = ChatMessage(
            text: messageText,
            sendTime: (messageTimestamp as Timestamp).toDate(),
          );

          messageWidgets.add(messageWidget);
        }

        return ListView(
          reverse: true,
          children: messageWidgets,
        );
      },
    );
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  text,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Text(
                '${sendTime.toLocal()}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
