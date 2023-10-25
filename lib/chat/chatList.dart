import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_flutter/chat/chat.dart';
import 'package:project_flutter/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChatList());
}

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('채팅 목록'),
        ),
        body: _chatting(),
      ),
    );
  }

  Widget _chatting() {
    return StreamBuilder(
      stream: _fs.collection("chat_rooms").orderBy("timestamp", descending: true).snapshots(),

      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {

        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = snap.data!.docs[index];
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            // 문서의 ID를 roomId 변수로 설정
            String roomId = doc.id;

            print(snap.data!.docs.length,);

            return ListTile(
              title: Text('${data['user']}'),
              subtitle: Text("못하겟따"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatApp(chatRoomId: roomId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
