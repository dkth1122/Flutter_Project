import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_sample1/userJoin.dart';
import 'package:firebase_sample1/userModel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 필요한 패키지를 추가합니다.
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
      ChangeNotifierProvider(
        create: (context) => UserModel(),
        child: MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  final TextEditingController _pwd = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _id,
              decoration: InputDecoration(labelText: '아이디'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _pwd,
              obscureText: true,
              decoration: InputDecoration(labelText: '비밀번호'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              child: Text('로그인'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Join(),
                  ),
                );
              },
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    String id = _id.text;
    String password = _pwd.text;

    final userDocs = await _fs.collection('userList')
        .where('id', isEqualTo: id)
        .where('pwd', isEqualTo: password).get();

    if (userDocs.docs.isNotEmpty) {
      Provider.of<UserModel>(context, listen: false).login(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('성공적으로 로그인되었습니다!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('아이디나 패스워드를 다시 확인해주세요.')),
      );
    }
  }
}