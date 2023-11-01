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
    return Scaffold(
        appBar: AppBar(title: Text("채팅 목록"), backgroundColor: Color(0xFFFCAF58),),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                SizedBox(height: 10),
                Expanded(child: _listChat()),
              ],
            ),
          ),
        ),
      );
  }

  Widget _listChat() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collectionGroup("chat").snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
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

            final user1Value = data['user1'] as String?;
            final user2Value = data['user2'] as String?;
            String chatTitle = '';
            if (user1Value == user1 || user2Value == user1) {
              if (user1Value == user1) {
                chatTitle = '$user2Value 님과의 채팅' ?? "No User";
              } else {
                chatTitle = '$user1Value 님과의 채팅' ?? "No User";
              }

              // 이 부분에서 서브컬렉션의 필드 값을 가져올 수 있음
              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance.collection('chat').doc(document.id).collection('messages').get(),
                builder: (context, messageSnap) {
                  if (messageSnap.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  final messages = messageSnap.data?.docs;


                  // 이제 messages 리스트에 서브컬렉션의 문서 목록이 있...없던데..
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatApp(roomId: document.id),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              // Add profile image here
                              backgroundImage: AssetImage('assets/dog1.PNG'),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chatTitle,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  // 서브컬렉션의 필드 값을 이용하여 마지막 메시지 설정
                                  Text(
                                    '마지막 메시지: ${getLastMessage(messages!)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '10:30 AM', // Add message timestamp here
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Color(0xFFFCAF58),
                                  child: Text(
                                    '2', // Add unread message count here
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Container();
            }
          },
        );
      },
    );
  }

  String getLastMessage(List<QueryDocumentSnapshot> messages) {
    if (messages == null || messages.isEmpty) {
      return '메시지가 없습니다1.';
    }

    // 서브컬렉션의 메시지 목록을 정렬해서 가장 마지막 메시지의 내용을 가져옴
    final sortedMessages = messages
        .map((message) => message.data() as Map<String, dynamic>)
        .where((messageData) => messageData['text'] != null || messageData['imageUrl'] != null)
        .toList();

    if (sortedMessages.isEmpty) {
      return '메시지가 없습니다2.';
    }

    final lastMessageData = sortedMessages.last;
    final lastMessageText = lastMessageData['text'] as String?;
    final lastMessageImageUrl = lastMessageData['imageUrl'] as String?;

    if (lastMessageText != null) {
      return lastMessageText;
    } else if (lastMessageImageUrl != null) {
      return '이미지를 보냈습니다.';
    } else {
      return '메시지가 없습니다3.';
    }
  }





}