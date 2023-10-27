import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../join/userModel.dart';

class ChatApp extends StatelessWidget {
  final String roomId;
  ChatApp({required this.roomId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      home: ChatScreen(roomId: roomId),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String roomId;

  ChatScreen({required this.roomId});

  @override
  State createState() => ChatScreenState(roomId: roomId);
}

class ChatScreenState extends State<ChatScreen> {
  final String roomId;
  ChatScreenState({required this.roomId});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  late String user1;

  File? _image; // 이미지 파일을 저장할 변수




  @override
  void initState() {
    super.initState();
    UserModel um = Provider.of<UserModel>(context, listen: false);
    if (um.isLogin) {
      user1 = um.userId!;
    } else {
      user1 = "없음";
      print("로그인 안됨");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat App', textAlign: TextAlign.center, style: TextStyle(color: Colors.black)),// 제목 텍스트 설정
        backgroundColor: Colors.white, // AppBar 배경색 설정
        actions: <Widget>[ // 오른쪽 상단에 아이콘 추가
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // 설정 아이콘을 눌렀을 때 수행할 동작
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // 검색 아이콘을 눌렀을 때 수행할 동작
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ChatMessages(roomId: roomId, user1: user1),
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
                IconButton(
                    onPressed: () async{
                      // 이미지 저장
                      Directory dir = await getApplicationDocumentsDirectory();
                      Directory imgDir = Directory('${dir.path}/img');
                      String name = DateTime.now().millisecondsSinceEpoch.toString();

                      if (!await imgDir.exists()) {
                        await imgDir.create(); // 폴더 생성
                        try {
                          File targetFile = File('${imgDir.path}}/$name');
                          // targetFile.path 얘를 db에 저장 후 호출 때 사용
                          // 보통 안드로이드 => /data/user/0/com.example.indie_spot/app_flutter
                          // 아이폰 => /Users/your_user_name/Library/Developer/CoreSimulator/Devices/DEVICE_ID/data/Containers/Data/Application/APP_ID/Documents
                          print('저장경로 확인 ==> ${targetFile.path}');
                          // _image는 File객체
                          await _image!.copy(targetFile.path);
                          // 저장 후 호출 시에는 Image.file(imageFile) 형태로 사용할 것
                        } catch (e) {
                          print("에러메세지: $e");
                        }
                      }
                    },
                    icon: Icon(Icons.photo_size_select_actual, color: Colors.grey,)
                )
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

      _firestore
          .collection('chat')
          .doc(roomId)
          .collection('message')
          .add({'text': text, 'sendTime': FieldValue.serverTimestamp(), 'user': user1,})
          .then((_) {
        _messageController.clear();
      })
          .catchError((error) {
        print('Error: $error');
      })
          .whenComplete(() {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }
}

class ChatMessages extends StatelessWidget {
  final String roomId;
  final String user1;

  ChatMessages({
    required this.roomId,
    required this.user1,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .doc(roomId)
          .collection('message')
          .orderBy('sendTime', descending:true )
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
            final messageTimestamp = message['sendTime'];
            //final user = message['user'];

            //final isCurrentUser = user == user1;

            final messageWidget = ChatMessage(
              text: messageText,
              sendTime: messageTimestamp != null ? messageTimestamp.toDate(): DateTime.now(), isCurrentUser: true,
              //isCurrentUser: isCurrentUser,
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
          if (!isCurrentUser)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                DateFormat('yy.MM.dd\na h:mm').format(sendTime),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          Column(
            crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isCurrentUser ? Colors.orange : Colors.grey,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  text,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              // Add an image upload button here
            ],
          ),
        ],
      ),
    );
  }
}