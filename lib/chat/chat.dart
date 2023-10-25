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
  List<Map<String, dynamic>> messages = [];

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
          // 여기서는 데이터가 아직 도착하지 않았을 때의 상황을 처리합니다.
          return CircularProgressIndicator(); // 로딩 표시나 다른 대체 UI를 보여줄 수 있습니다.
        }

        if (snap.hasError) {
          // 오류 처리
          return Text('Error: ${snap.error}');
        }

        // snap.data가 null이 아닌지 확인
        if (snap.data != null) {
          return ListView(
            children: snap.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['text']),
                subtitle: Text("작성일 : ${data['sendTime'].toDate().toString()}"),
              );
            }).toList(),
          );
        } else {
          // 데이터가 null이면 빈 화면을 보여줄 수 있습니다.
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
              child:_chatList()
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
