import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../firebase_options.dart';
import '../join/userModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Question());
}


class Question extends StatefulWidget {
  const Question({super.key});

  @override
  State<Question> createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _content = TextEditingController();
  String sessionId = "";


  void _addBoard() async {
    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      sessionId = um.userId!;
      print(sessionId);
    } else {
      sessionId = "";
      print(sessionId);
    }
    if (_title.text.isNotEmpty && _content.text.isNotEmpty) {
      CollectionReference board = FirebaseFirestore.instance.collection('question');

      await board.add({
        'title': _title.text,
        'content': _content.text,
        'user': sessionId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _title.clear();
      _content.clear();
    } else {
      print("제목 또는 내용을 입력해주세요.");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("1:1 문의하기"),backgroundColor: Color(0xFFFF8C42),),
      body: Container(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: [
            Text("문의 등록", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            SizedBox(height: 10,),
            Text("자주 묻는 질문에 대한 답변은 FAQ 페이지에서 확인해 보세요", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
            SizedBox(height: 10,),
            Text("[문의하시기전에 확인해 주세요!]", style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(22, 158, 230, 1)),),
            Text("Fixer 4 U는 서비스 중개 플랫폼 입니다. 서비스 작업 의뢰는 Fixer 4 U 사이트에서 전문가에게 직접 문의해 주시기를 부탁드립니다.", style: TextStyle(fontWeight: FontWeight.bold,color: Color.fromRGBO(22, 158, 230, 1))),
            Text("또한, 계정 인증에 관한 문의는 '휴대전화 번호' 또는 '이메일 주소'를 전달해 주시면 빠른 안내가 가능합니다.", style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromRGBO(22, 158, 230, 1))),
            SizedBox(height: 10,),
            Text("제목", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            Container(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _title,
                decoration: InputDecoration(
                  border: OutlineInputBorder(), // 테두리 스타일 지정
                ),
              ),
            ),

            SizedBox(height: 10),
            Text("내용", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            Container(
              padding: EdgeInsets.all(10),
              height: 200, // 전체 컨테이너의 높이
              child: TextFormField(
                controller: _content,
                style: TextStyle(fontSize: 20),
                maxLines: 20,
                decoration: InputDecoration(
                  border: OutlineInputBorder(), // 테두리 스타일 지정
                ),
              ),
            ),

            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: _addBoard,
                child: Text("제출"),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
