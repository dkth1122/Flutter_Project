import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  //마지막 메시지 시간
  String timeFormat = "";

  //내가 아닌 유저
  String otherUser = "";

  //이미지
  String url = "assets/profile.png";

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
        backgroundColor: Colors.white10,
        elevation: 0,
        title: Text(
          '대화 목록',
          style: TextStyle(
            color: Color(0xff424242),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color(0xff424242),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
          return Center(child: CircularProgressIndicator());
        }

        final chatList = snap.data?.docs ?? [];

        if (chatList.isEmpty) {
          return Center(child: Text('No chats available'));
        }

        return ListView.builder(
          itemCount: chatList.length,
          itemBuilder: (context, index) {
            final document = chatList[index];
            final data = document.data() as Map<String, dynamic>;
            final String? user1Value = data['user1'] as String?;
            final String? user2Value = data['user2'] as String?;
            final String? status = data['status'] as String?;

            // 사용자 ID에 따라 필터링
            if (user1Value != user1 && user2Value != user1) {
              // 사용자1과 일치하지 않는 경우 또는 사용자2와 일치하지 않는 경우 이 채팅방을 건너뜀
              return Container();
            }

            if (status == '$user1 D') {
              // 상태가 "D"인 채팅방은 건너뛰기
              return Container();
            }

            final chatTitle = (user1Value != null && user1Value == user1)
                ? '$user2Value 님과의 대화'
                : '$user1Value 님과의 대화';

            final String roomName = document.id;

            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('chat')
                  .doc(roomName)
                  .collection('message')
                  .orderBy('sendTime', descending: true)
                  .limit(1)
                  .get(),
              builder: (context, AsyncSnapshot<QuerySnapshot> lastMessageSnapshot) {
                if (lastMessageSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (lastMessageSnapshot.hasError) {
                  return Center(child: CircularProgressIndicator());
                }

                String lastMessageText = 'No last message';
                Widget? trailingWidget;

                if (lastMessageSnapshot.hasData && lastMessageSnapshot.data!.docs.isNotEmpty) {
                  final lastMessageData = lastMessageSnapshot.data!.docs.first.data() as Map<String, dynamic>;
                  lastMessageText = lastMessageData['text'] as String? ?? 'No last message';
                  final String? lastMessageImageUrl = lastMessageData['imageUrl'] as String?;

                  if (lastMessageImageUrl != null && lastMessageImageUrl!.isNotEmpty) {
                    lastMessageText = "이미지를 보냈습니다.";
                  }
                  // sendTime을 표시하기 위한 코드 수정
                  final lastMessageTime = lastMessageData['sendTime'] as Timestamp?;
                  final messageDateTime = lastMessageTime?.toDate();
                  timeFormat = DateFormat.jm().format(messageDateTime!);
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
                      // Firestore 데이터를 가져올 때 사용자 데이터를 초기화
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
                            backgroundImage: AssetImage(url),
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
                                    color: Color(0xff424242),
                                  ),
                                ),
                                SizedBox(height: 4),
                                // 서브컬렉션의 필드 값을 이용하여 마지막 메시지 설정
                                Text(
                                  lastMessageText,
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
                                timeFormat,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              SizedBox(height: 8),
                              //챗봇용
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Color(0xFFFCAF58),
                                child: TextButton(
                                  onPressed: () {
                                    // 물음표 버튼을 클릭했을 때 ChatResponsePage로 이동하고 doc.id 전달
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatResponsePage(roomId: document.id),
                                      ),
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
                    .update({'status': '$user1 D'})
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
              child: Text('취소'),)
          ],
        );
      },
    );
  }
}