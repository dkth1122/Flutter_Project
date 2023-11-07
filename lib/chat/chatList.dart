import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../expert/ad_form.dart';
import '../join/userModel.dart';
import 'chat.dart';
import 'chatBot.dart';

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
        title: Row(
          children: [
            Text("채팅 목록"),
            TextButton(onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdForm(),
                  )
              );
            }, child: Text("이동"))
          ],
        ),
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


        if (chatList == null || chatList.isEmpty) {
          return Center(child: Text('No chats available'));
        }
        // "status" 필드가 'D'인 채팅을 필터링
        final filteredChatList = chatList.where((document) {
          final data = document.data() as Map<String, dynamic>?;
          if (data == null || (!data.containsKey('user1') && !data.containsKey('user2'))) {
            return false;
          }

          final status = data['status'] as String?;
          return status != 'D';
        }).toList();


        return chatList == null || chatList.isEmpty
            ? Center(child: Text('No chats available'))
            : ListView.builder(
          itemCount: filteredChatList.length,
          itemBuilder: (context, index) {
            final document = filteredChatList[index];
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

              String roomName1 = '$user1' + '_' + '${data['user1'] as String?}';
              String roomName2 = '${data['user1'] as String?}' + '_' + '$user1';

              String roomName3 = '${data['user2'] as String?}' + '_' + '$user1';
              String roomName4 = '$user1' + '_' + '${data['user2'] as String?}';


              // 이 부분에서 서브컬렉션의 필드 값을 가져올 수 있음
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chat')
                    .where('roomId', whereIn: [roomName1, roomName2, roomName3, roomName4])
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

                          print("내용 ====> $lastMessageText");

                          // 이제 lastMessageText 또는 lastMessageImageUrl을 사용할 수 있습니다.
                          if (lastMessageText != null) {
                            lastMessages[roomName] = lastMessageText;
                          } else if (lastMessageImageUrl != null) {
                            // 이미지 처리
                            lastMessageText = "이미지를 보냈습니다.";
                            lastMessages[roomName] = lastMessageText;
                          } else {
                            lastMessages[roomName] = lastMessageText;
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
                      onLongPress: () {
                        // 채팅방을 나가기 위한 확인 대화 상자 표시
                        _showLeaveChatRoomDialog(context, document.id);
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
                                    lastMessages[document.id] ?? '이미지를 보냈습니다.',
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
                                // Text(
                                //   '10:30 AM', // Add message timestamp here
                                //   style: TextStyle(
                                //     fontSize: 12,
                                //     color: Colors.grey,
                                //   ),
                                // ),
                                SizedBox(height: 8),
                                //알림용,,,
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Color(0xFFFCAF58),
                                  child: TextButton(
                                    onPressed: (){
                                      // 물음표 버튼을 클릭했을 때 ChatResponsePage로 이동하고 doc.id 전달
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatResponsePage(roomId: document.id),
                                          )
                                      );
                                    },
                                    child: Text("?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),),
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

  void _showLeaveChatRoomDialog(BuildContext context, String roomId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('채팅방 나가기'),
          content: Text('정말로 이 채팅방을 나가시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                // "status" 필드를 "D"로 설정하여 채팅방 비활성화
                FirebaseFirestore.instance
                    .collection('chat')
                    .doc(roomId)
                    .update({'status': 'D'})
                    .then((value) {
                  Navigator.of(context).pop();
                });
              },
              child: Text('나가기'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
          ],
        );
      },
    );
  }
}