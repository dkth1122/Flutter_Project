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
  late String userAId;
  late String userBId;

  // 채팅방 문서 ID => 방 이름 생성
  late String chatRoomId;

  @override
  void initState() {
    super.initState();
    final Uuid uuid = Uuid();
    userAId = uuid.v4();
    userBId = uuid.v4();
    chatRoomId = 'chat_room_${userAId}_${userBId}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat App'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ChatMessages(chatRoomId: chatRoomId, userAId: userAId),
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
        'user': userAId, // 현재 사용자를 나타내는 ID
      });
      _messageController.clear();
    }
  }
}

class ChatMessages extends StatelessWidget {
  final String chatRoomId;
  final String userAId; // userAId를 추가

  ChatMessages({
    required this.chatRoomId,
    required this.userAId, // 생성자에서 userAId를 받음
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat_rooms/$chatRoomId/messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final messages = snapshot.data?.docs;

        if (messages != null && messages.isNotEmpty) {
          List<Widget> messageWidgets = [];
          for (var message in messages) {
            final messageText = message['text'];
            final messageTimestamp = message['timestamp'];
            final user = message['user'];

            final isCurrentUser = user == userAId; // 현재 사용자인 경우

            final messageWidget = ChatMessage(
              text: messageText,
              sendTime: (messageTimestamp as Timestamp).toDate(),
              isCurrentUser: isCurrentUser,
            );

            messageWidgets.add(messageWidget);
          }

          return ListView(
            reverse: true,
            children: messageWidgets,
          );
        } else {
          return Center(
            child: Text('No messages available.'),
          );
        }
      },
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final DateTime sendTime;
  final bool isCurrentUser;

  ChatMessage({
    required this.text,
    required this.sendTime,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isCurrentUser ? Colors.blue : Colors.grey,
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
