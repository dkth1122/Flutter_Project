import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../join/userModel.dart';

class ChatApp extends StatelessWidget {
  final String roomId;
  ChatApp({required this.roomId});

  @override
  Widget build(BuildContext context) {
    return ChatScreen(roomId: roomId);
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
      print(user1);
    } else {
      user1 = "없음";
      print("로그인 안됨");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat App', textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFFCAF58),
        actions: <Widget>[
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
                  icon: Icon(Icons.send, color: Colors.grey),
                  onPressed: () {
                    _handleOnSubmit();
                  },
                ),
                IconButton(
                  onPressed: () {
                    _handleImageUpload(); // 이미지 선택
                  },
                  icon: Icon(Icons.photo_size_select_actual, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (_isLoading)
            CircularProgressIndicator(),
          if (_image != null)
            Column(
              children: [
                //선택한 이미지 표시
                Image.file(_image!, width: 100, height: 100),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _image = null;
                    });
                  },
                  icon: Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _handleImageUpload() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
      });
    } else {
      // 이미지 선택이 취소되면 이미지 변수 초기화
      setState(() {
        _image = null;
      });
    }
  }

  void _handleOnSubmit() {
    final String text = _messageController.text;
    if (text.isNotEmpty || _image != null) {
      setState(() {
        _isLoading = true;
      });

      if (_image != null) {
        final storageRef = FirebaseStorage.instance.ref().child('chat_images/${Uuid().v4()}.png');
        final uploadTask = storageRef.putFile(_image!);

        uploadTask.then((TaskSnapshot taskSnapshot) {
          return taskSnapshot.ref.getDownloadURL().then((downloadUrl) {
            // 이미지 URL에 .png 확장자를 추가
            downloadUrl += '.png';

            _firestore
                .collection('chat')
                .doc(roomId)
                .collection('message')
                .add({
              'text': text,
              'imageUrl': downloadUrl, // 확장자가 추가된 이미지 URL 저장
              'sendTime': FieldValue.serverTimestamp(),
              'user': user1,
            }).then((_) {
              setState(() {
                _image = null;
                _messageController.clear();
              });
            }).catchError((error) {
              print('Error: $error');
            }).whenComplete(() {
              setState(() {
                _isLoading = false;
              });
            });
          });
        });
      } else {
        _firestore
            .collection('chat')
            .doc(roomId)
            .collection('message')
            .add({
          'text': text,
          'sendTime': FieldValue.serverTimestamp(),
          'user': user1,
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
          .orderBy('sendTime', descending: true)
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
            final messageData = message.data();
            if (messageData != null) {
              final Map<String, dynamic> messageMap = messageData as Map<String, dynamic>;

              final messageText = messageMap['text'];
              final messageTimestamp = messageMap['sendTime'];
              final messageImg = messageMap['imageUrl'];
              late ChatMessage messageWidget;


              if (messageText != null && messageTimestamp != null) {

                if(messageImg != null){
                  messageWidget = ChatMessage(
                    text: messageText,
                    sendTime: (messageTimestamp as Timestamp).toDate(),
                    isCurrentUser: messageMap['user'] == user1 ? true : false,
                    imageUrl: messageImg,
                  );
                }else{
                  messageWidget = ChatMessage(
                  text: messageText,
                  sendTime: (messageTimestamp as Timestamp).toDate(),
                  isCurrentUser: messageMap['user'] == user1 ? true : false,
                );

                }

                messageWidgets.add(messageWidget);
              }
            }
          }

          return ListView(
            reverse: true,
            children: messageWidgets,
          );
        } else {
          return Center(
            child: Text('메시지가 없습니다.'),
          );
        }
      },
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String? text;
  final String? imageUrl;
  final DateTime sendTime;
  final bool isCurrentUser;

  ChatMessage({
    this.text,
    this.imageUrl,
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
              padding: EdgeInsets.only(left: 8.0),
            ),
          Row(
            children: <Widget>[
              if (isCurrentUser)
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: Text(
                    DateFormat('yy.MM.dd\n HH:mm').format(sendTime),
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: isCurrentUser ? Color(0xFFFF8C42) : Color(0xFF4E598C),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: <Widget>[
                    if (text != null)
                      Text(
                        text!,
                        style: TextStyle(color: Colors.white),
                      ),
                    if (imageUrl != null)
                      Image.network(
                        imageUrl!,
                        width: 100, // 이미지의 너비 설정
                        height: 100, // 이미지의 높이 설정
                      ),
                  ],
                ),
              ),
              if (!isCurrentUser)
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    DateFormat('yy.MM.dd\n HH:mm').format(sendTime),
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
