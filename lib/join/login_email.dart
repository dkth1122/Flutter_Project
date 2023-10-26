import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 필요한 패키지를 추가합니다.
import 'package:project_flutter/join/loginSuccess.dart';
import 'package:project_flutter/join/userModel.dart';
import 'package:project_flutter/myPage/my_page.dart';
import 'package:provider/provider.dart';

import '../firebase_options.dart';
import 'join.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( ChangeNotifierProvider(
    create: (context) => UserModel(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Pretendard', // 사용할 폰트 패밀리 이름
      ),
      title: '로그인',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseFirestore _fs = FirebaseFirestore.instance; // Firestore 인스턴스를 가져옵니다.
  final TextEditingController _id = TextEditingController();
  final TextEditingController _pw = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인', style: TextStyle(fontFamily: 'Pretendard'),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _id,
              decoration: InputDecoration(
                labelText: '아이디',
                labelStyle: TextStyle(
                  color: Color(0xff328772), // 포커스된 상태의 라벨 텍스트 색상
                ),

                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff328772), width: 2.0,), // 포커스된 상태의 테두리 색상 설정
                  borderRadius: BorderRadius.circular(10.0), // 포커스된 상태의 테두리 모양 설정 (선택 사항)
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xfff48752),  width: 2.0,), // 비활성 상태의 테두리 색상 설정
                  borderRadius: BorderRadius.circular(10.0), // 비활성 상태의 테두리 모양 설정 (선택 사항)
                ),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _pw,
              obscureText: true,
              decoration: InputDecoration(
                labelText: '패스워드',
                labelStyle: TextStyle(
                  color: Color(0xff328772), // 포커스된 상태의 라벨 텍스트 색상
                ),

                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xff328772), width: 2.0,),
                  // 포커스된 상태의 테두리 색상 설정
                  borderRadius: BorderRadius.circular(10.0),

                  // 포커스된 상태의 테두리 모양 설정 (선택 사항)
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xfff48752),  width: 2.0,), // 비활성 상태의 테두리 색상 설정
                  borderRadius: BorderRadius.circular(10.0), // 비활성 상태의 테두리 모양 설정 (선택 사항)
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(Size(500, 55)),
                backgroundColor: MaterialStateProperty.all(Color(0xfff48752)),
                foregroundColor: MaterialStateProperty.all(Color(0xff328772)), // 텍스트 색상 변경
                // 너비와 높이 조절
              ),
              onPressed: _login,
              child: Text('로그인'),
            ),
            Expanded(child: SizedBox(height: 10,)),

            ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(Size(500, 55)),
                backgroundColor: MaterialStateProperty.all(Colors.white),
                side: MaterialStateProperty.all(BorderSide(
                  color: Color(0xff424242),
                  width: 2.0,
                )),

              ),

              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Join(),
                  ),
                );
              },
              child: Text('회원가입', style: TextStyle(fontFamily: 'Pretedard', color: Colors.black),),
            ),


          ],
        ),
      ),
    );
  }

  void _login() async {
    String id = _id.text;
    String password = _pw.text;

    final userDocs = await _fs.collection('userList')
        .where('id', isEqualTo: id)
        .where('pw', isEqualTo: password).get();

    if (userDocs.docs.isNotEmpty) {
      Provider.of<UserModel>(context, listen: false).login(id);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyPage(),
        ),
      );
      _id.clear();
      _pw.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('아이디나 패스워드를 다시 확인해주세요.')),
      );
    }
  }
}