import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chat.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("채팅 목록")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // 여기에 새 채팅 추가 로직을 구현하세요.
                    // 예를 들어, Navigator를 사용하여 다음 화면(Chat)으로 이동할 수 있습니다.
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => Chat()),
                    // );
                  },
                  child: Text("새 채팅 시작"),
                ),
                SizedBox(height: 10),
                Expanded(child: _listChat()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listChat() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("chat").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        return ListView(
          children: snap.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['user2']),
              subtitle: Text(data['user1']),
              onTap: () {
                // 여기에서 선택한 채팅을 열도록 구현할 수 있습니다.
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatApp(roomId: data['roomId']),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}