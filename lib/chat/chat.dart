import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

  Widget _chatList(){
    return StreamBuilder(
      //호출한 데이터를 stream에 담아야함
      //딱 한번만 호출 하려면 : 메소드 체이닝 기법으로 FirebaseFirestore.instance.collection("users").snapshots(), 로 담기 가능
      //여러 번 사용하려면 메소드로 만들어서 따로 뺴야 함
        stream: FirebaseFirestore.instance.collection("chat").snapshots(),
        //데이터 실시간 처리를 위해 단순한 스냅샷이 아닌 async 스냅샷으로 지정
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap){
          //------위에 까지는 데이터 호출
          return ListView(
            children:
            //호출 결과 자체가 List형태라서 칠드런의 [] 제거 가능
            //map안에 파라미터를 가지는 콜백 함수 호출
            snap.data!.docs.map((DocumentSnapshot document){
              //문서에서 데이터를 가져와서 data 변수에 담음 => 이 데이터는 맵 형식으로 표현됨
              //<key, value>
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['name']),
                subtitle: Text("나이 : ${data['age']}"),
              );
            }).toList(),
          );
        }
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
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chat')
                    .orderBy('sendTime', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    messages = (snapshot.data?.docs ?? []).map((doc) => doc.data() as Map<String, dynamic>).toList();
                    print(messages);
                    return ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return ListTile(
                          title: Text(message['text']),
                          subtitle: Text(message['user']),
                        );
                      },
                    );
                  }
                },
              ),
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
