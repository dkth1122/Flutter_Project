import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';
import 'chat.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {

  String user1 = "";
  String user2 = "";

  @override
  void initState() {
    super.initState();
    UserModel um = Provider.of<UserModel>(context, listen: false);
    user2 = "UserB";
    if (um.isLogin) {
      // 사용자가 로그인한 경우
      user1 = um.userId!;

    } else {
      // 사용자가 로그인하지 않은 경우
      user1 = "없음";
      print("로그인 안됨");
    }
  }

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
        if (snap.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Display loading indicator while waiting
        }

        final chatList = snap.data?.docs;

        return chatList == null || chatList.isEmpty
            ? Center(child: Text('No chats available'))
            : ListView.builder(
          itemCount: chatList.length,
          itemBuilder: (context, index) {
            final document = chatList[index];
            final data = document.data() as Map<String, dynamic>?;
            if (data == null || (!data.containsKey('user1') && !data.containsKey('user2'))) {
              return Container();
            }

            // My user ID
            final user1Value = data['user1'] as String?;
            final user2Value = data['user2'] as String?;

            if (user1Value == user1 || user2Value == user1) {
              return ListTile(
                title: Text(user1Value ?? "No User"), // Handle nullable string
                subtitle: Text(user2Value ?? "No User"), // Handle nullable string
                onTap: () {
                  print("아이디 ===> ${document.id}");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatApp(roomId: document.id),
                    ),
                  );
                },
              );
            } else {
              return Container(); // Don't display if it doesn't match my user ID
            }
          },
        );
      },
    );
  }


}