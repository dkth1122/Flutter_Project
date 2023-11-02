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
  Map<String, String> lastMessages = {}; // 각 채팅방의 마지막 메시지를 저장할 맵

  @override
  void initState() {
    super.initState();
    UserModel um = Provider.of<UserModel>(context, listen: false);
    user2 = "UserB";
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
        title: Text("채팅 목록"),
        backgroundColor: Color(0xFFFCAF58),
      ),
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
            if (data == null ||
                (!data.containsKey('user1') && !data.containsKey('user2'))) {
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

              String roomName1 = '$user1' + '_' + '$user2Value';
              String roomName2 = '$user2Value' + '_' + '$user1';


              // 이 부분에서 서브컬렉션의 필드 값을 가져올 수 있음
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chat')
                    .where('roomId', whereIn: [roomName1, roomName2])
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  final chatRooms = snapshot.data?.docs;

                  if (chatRooms != null && chatRooms.isNotEmpty) {
                    for (var room in chatRooms) {
                      final roomName = room['roomId'];

                      // 해당 채팅방에 대한 마지막 메시지 쿼리
                      FirebaseFirestore.instance
                          .collection('chat')
                          .doc(roomName)
                          .collection('message')
                          .orderBy('sendTime', descending: true)
                          .limit(1) // 마지막 메시지 1개만 가져오도록 설정
                          .get()
                          .then((QuerySnapshot querySnapshot) {
                        if (querySnapshot.docs.isNotEmpty) {
                          final lastMessage = querySnapshot.docs[0];
                          final lastMessageData =
                          lastMessage.data() as Map<String, dynamic>;

                          String lastMessageText =
                          lastMessageData['text'] as String;
                          var lastMessageImageUrl =
                          lastMessageData['imageUrl'];

                          // 이제 lastMessageText 또는 lastMessageImageUrl을 사용할 수 있습니다.
                          if (lastMessageText != null) {
                            lastMessages[roomName] = lastMessageText;
                            setState(() {}); // 상태 업데이트
                          } else if (lastMessageImageUrl != null) {
                            // 이미지 처리
                          } else {
                            // 메시지가 없을 때 처리
                          }
                        }
                      });
                    }
                  }

                  return Card(
                    elevation: 3,
                    margin:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChatApp(roomId: document.id),
                          ),
                        );
                        // ChatApp에서 돌아왔을 때 메시지를 읽었음을 표시
                        await _markMessagesAsRead(document.id);
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
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
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
                                    lastMessages[document.id] ?? '',
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


  Future<void> _markMessagesAsRead(String roomId) async {
    final myId = user1; // 현재 사용자의 ID를 가져오는 방법을 구현해야 합니다.
    final messagesRef =
    FirebaseFirestore.instance.collection('chat').doc(roomId).collection(
        'message');

    final messagesQuery = await messagesRef
        .where('user', isEqualTo: myId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final messageDoc in messagesQuery.docs) {
      await messageDoc.reference.update({
        'isRead': true,
      });
    }
  }
}