import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat List'),
      ),
      body: ChatList(),
    );
  }
}

class ChatList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('chat').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        List<QueryDocumentSnapshot> chatRooms = snapshot.data!.docs;

        return ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index];
            final roomId = chatRoom.id;

            // 여기에서 필요한 정보를 chatRoom으로부터 가져오고 UI에 출력할 수 있습니다.
            // 예를 들어, 상대방의 이름, 마지막 메시지 등을 가져와서 출력할 수 있습니다.

            return ListTile(
              title: Text(roomId), // 채팅 방 이름 또는 정보를 여기에 표시
              onTap: () {
                // 채팅 방을 열거나 해당 채팅으로 이동하는 코드를 여기에 추가
              },
            );
          },
        );
      },
    );
  }
}
