import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_flutter/join/userModel.dart';
import 'package:project_flutter/main.dart';
import 'package:provider/provider.dart';
import '../admin/adminDomain.dart';
import '../firebase_options.dart';
import 'ForgotPassword.dart';
import 'join.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Pretendard',
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
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  final TextEditingController _userId = TextEditingController();
  final TextEditingController _pw = TextEditingController();

  Widget _buildTextField(String labelText, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: labelText == '패스워드',
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Color(0xff328772),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xff328772), width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xfff48752), width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인', style: TextStyle(fontFamily: 'Pretendard')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTextField('아이디', _userId),
            SizedBox(height: 8),
            _buildTextField('패스워드', _pw),
            SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(Size(500, 55)),
                backgroundColor: MaterialStateProperty.all(Color(0xfff48752)),
                foregroundColor: MaterialStateProperty.all(Color(0xff328772)),
              ),
              onPressed: _login,
              child: Text('로그인'),
            ),

            TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgotPasswordTabBar()
              ));
            }, child: Text("아이디/비밀번호 찾기")),
            Expanded(child: SizedBox(height: 10)),
            ElevatedButton(
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(Size(500, 55)),
                backgroundColor: MaterialStateProperty.all(Colors.white),
                side: MaterialStateProperty.all(
                  BorderSide(
                    color: Color(0xff424242),
                    width: 2.0,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Join(),
                  ),
                );
              },
              child: Text(
                '회원가입',
                style: TextStyle(fontFamily: 'Pretendard', color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    String id = _userId.text;
    String password = _pw.text;

    final userDocs = await _fs
        .collection('userList')
        .where('userId', isEqualTo: id)
        .where('pw', isEqualTo: password)
        .get();

    if (userDocs.docs.isNotEmpty) {
      Provider.of<UserModel>(context, listen: false).login(id);

      if (id == 'admin') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDomainPage(),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      }

      _userId.clear();
      _pw.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('아이디나 패스워드를 다시 확인해주세요.')),
      );
    }
  }
}