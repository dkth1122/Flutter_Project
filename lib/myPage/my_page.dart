import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../chat/chat.dart';
import '../chat/chatList.dart';
import '../join/userModel.dart';
import '../product.dart';

class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    UserModel userModel = Provider.of<UserModel>(context); // 사용자 ID를 가져옴
    String? userId = userModel.userId;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "마이페이지",
          style: TextStyle(color: Colors.grey),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: IconThemeData(color: Colors.grey),
        leading: IconButton(
          icon: Icon(Icons.add_alert),
          onPressed: () {
            // 왼쪽 아이콘을 눌렀을 때 수행할 작업을 여기에 추가합니다.
          },
        ),
        actions: [
          TextButton(
            child: Text(
              "계정 설정",
              style: TextStyle(color: Colors.grey),
            ),
            onPressed: () {
              // 오른쪽 아이콘을 눌렀을 때 수행할 작업을 여기에 추가합니다.
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('dog4.png'),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(5),
                        child: Text("의뢰인"),
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                      Text(
                        userId?? '', // userList가 null이거나 userId 키가 없을 경우 빈 문자열 반환
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.white),
                          side: MaterialStateProperty.all(BorderSide(
                            color: Color(0xff424242),
                            width: 0.5,
                          )),
                        ),
                        child: Text(
                          "👀전문가로전환",
                          style: TextStyle(color: Color(0xff424242)),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.all(20.0),
            width: 400,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          Divider(
            color: Colors.grey,
            thickness: 10.0,
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text("내 프로젝트", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Container(
                  child: Column(
                    children: [
                      Text("요구사항을 작성하시고, 딱 맞는 전문가와의 거래를 진행하세요"),
                      ElevatedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.white),
                          side: MaterialStateProperty.all(BorderSide(
                            color: Color(0xff424242),
                            width: 0.5,
                          )),
                        ),
                        child: Text(
                          "프로젝트 의뢰하기",
                          style: TextStyle(color: Color(0xff424242)),
                        ),
                      )
                    ],
                  ),
                  margin: EdgeInsets.all(20.0),
                  width: 450,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xfff48752),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                )
              ],
            ),
          ),
          Divider(
            color: Colors.grey,
            thickness: 10.0,
          ),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => Product())
                  );
                },
                icon: Icon(Icons.add_circle_outline)
            ),
            IconButton(
                onPressed: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => ChatApp(chatRoomId: 'chatRoomId',))
                  );
                },
                icon: Icon(Icons.chat)
            ),
            IconButton(
                onPressed: (){
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => ChatList())
                  );
                },
                icon: Icon(Icons.chat_outlined)
            ),
            IconButton(
              onPressed: () async {
                DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('userList').doc('id').get();
                Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyPage(),
                  ),
                );
              },
              icon: Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }
}
