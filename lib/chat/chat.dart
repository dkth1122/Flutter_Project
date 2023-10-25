import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:project_flutter/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final String chatRoomId = 'your_chat_room_id'; // 여기에 원하는 chatRoomId를 지정

  runApp(ChatApp(chatRoomId: chatRoomId));
}

class ChatApp extends StatelessWidget {

  final String chatRoomId;
  ChatApp({required this.chatRoomId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      home: ChatScreen(chatRoomId: chatRoomId),
    );
  }
}

class ChatScreen extends StatefulWidget {

  final String chatRoomId;
  ChatScreen({required this.chatRoomId});

  @override
  State createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  late String userAId;
  late String userBId;
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
        title: Text(
          '상대방 아이디',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),

      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Text("상대방이 계좌이체 등 직접 결제를 요구하면 거절하시고 \n 즉시 고객센터로 알려주세요", style: TextStyle(fontSize: 12,), textAlign: TextAlign.center,),
          ),
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
                  icon: Icon(Icons.send, color: Colors.grey,),
                  onPressed: () {
                    _handleOnSubmit();
                  },
                ),
              ],
            ),
          ),
          if (_isLoading)
            CircularProgressIndicator(),
        ],
      ),
    );
  }

  void _handleOnSubmit() {
    final String text = _messageController.text;
    if (text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      _firestore.collection('chat_rooms/$chatRoomId/messages').add({
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'user': userAId,
      }).then((_) {
        _messageController.clear();
      }).catchError((error) {
        print('Error: $error');
      }).whenComplete(() {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }
}

class ChatMessages extends StatelessWidget {
  final String chatRoomId;
  final String userAId;

  ChatMessages({
    required this.chatRoomId,
    required this.userAId,
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

            final isCurrentUser = user == userAId;

            final messageWidget = ChatMessage(
              text: messageText,
              sendTime: messageTimestamp != null
                  ? DateFormat('yy.MM.dd \n h:mm').format(messageTimestamp.toDate())
                  : DateFormat('yy.MM.dd \n h:mm').format(DateTime.now()),
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
  final String sendTime; // DateTime 대신 String으로 유지
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
          isCurrentUser
              ? Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Text(
              '${sendTime.toString()}',
              style: TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.left, // 자신의 메시지의 경우에는 왼쪽에 표시
            ),
          )
              : Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Text(
              '${sendTime.toString()}',
              style: TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.right, // 상대방 메시지의 경우에는 오른쪽에 표시
            ),
          ),

          Column(
            crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isCurrentUser ? Colors.orange : Colors.grey,
                  borderRadius: isCurrentUser
                      ? BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                  )
                      : BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
                ),
                child: Text(
                  text,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}