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
          color: Color(0xff424242),
        ),

      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF4E598C),
        hintColor: Color(0xFFFCAF58),
        fontFamily: 'Pretendard',
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: Colors.black, // 레이블 텍스트의 색상
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4E598C), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4E598C), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          // 여기에 필요한 다른 스타일을 추가할 수 있습니다.
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('로그인',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFFFCAF58), // 배경색 변경
          elevation: 1.0,
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
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
                  backgroundColor: MaterialStateProperty.all(Color(0xFF4E598C)),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: _login,
                child: Text('로그인'),
              ),

              TextButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgotPasswordTabBar()
                ));
              },
                style: TextButton.styleFrom(
                  foregroundColor: Color(0xFF4E598C),
                  backgroundColor: Colors.transparent, // 배경색을 투명하게 설정
                ),
                child: Text("아이디/비밀번호 찾기"),
              ),
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
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
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
      final userDoc = userDocs.docs.first;
      final delYn = userDoc['delYn'];

      if (delYn == 'Y') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('탈퇴한 사용자입니다.')),
        );
      } else {
        Provider.of<UserModel>(context, listen: false).login(id);

        final banDocs = await _fs
            .collection('ban')
            .where('uId', isEqualTo: id)
            .get();

        if (banDocs.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('정지된 계정입니다. 고객센터에게 문의해주세요.')),
          );
        } else {
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
        }

        _userId.clear();
        _pw.clear();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('아이디나 패스워드를 다시 확인해주세요.')),
      );
    }
  }

}