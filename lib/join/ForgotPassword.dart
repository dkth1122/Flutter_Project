import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../subBottomBar.dart';

class ForgotPasswordTabBar extends StatefulWidget {
  @override
  _ForgotPasswordTabBarState createState() => _ForgotPasswordTabBarState();
}

Future<String?> findId(String name, String email) async {
  String? foundId;
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userList')
        .where('name', isEqualTo: name)
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      foundId = querySnapshot.docs[0].get('userId');
    }
  } catch (e) {
    print('Error finding ID: $e');
  }
  return foundId;
}

Future<String?> findPw(String name, String id) async {
  String? foundPw;
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userList')
        .where('name', isEqualTo: name)
        .where('userId', isEqualTo: id)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      foundPw = querySnapshot.docs[0].get('pw');
    }
  } catch (e) {
    print('Error finding PW: $e');
  }
  return foundPw;
}

class _ForgotPasswordTabBarState extends State<ForgotPasswordTabBar> {
  final List<Widget> _tabs = [
    ForgotIdPage(),
    ForgotPasswordPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // 여기서 색상을 흰색으로 설정
        ),
        primaryColor: Colors.white,
        hintColor: Color(0xff424242),
        fontFamily: 'Pretendard',
        iconTheme: IconThemeData(
          color: Color(0xff424242), // 아이콘 색상 설정
          size: 24, // 아이콘 크기 설정
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xff424242), fontSize: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: Color(0xff424242), // 레이블 텍스트의 색상
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFF8C42), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFF8C42), width: 2.0),
            borderRadius: BorderRadius.circular(10.0),
          ),

        ),
      ),

      home: DefaultTabController(
        length: 2, // 탭의 수 (여기서는 2개)
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              '아이디 비밀번호 찾기',
              style: TextStyle(color: Color(0xff424242), fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 1.0,
            iconTheme: IconThemeData(color: Color(0xff424242)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () {},
              ),
            ],
            bottom: TabBar(
              tabs: [
                Tab(
                  text: '아이디',
                ),
                Tab(
                  text: '비밀번호',
                ),
              ],
              labelColor: Color(0xFFFF8C42), // 선택된 탭의 텍스트 컬러
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelColor: Color(0xFFFF8C42), // 선택되지 않은 탭의 텍스트 컬러
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFFF8C42), // 밑줄의 색상을 변경하려면 여기에서 지정
                    width: 3.0, // 밑줄의 두께를 조절할 수 있습니다.
                  ),
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              ForgotIdPage(),
              ForgotPasswordPage(),
            ],
          ),
          bottomNavigationBar: SubBottomBar(),
        ),
      ),

    );
  }
}

class ForgotIdPage extends StatelessWidget {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '이름과 가입한 이메일을 입력하세요.',
            style: TextStyle(fontSize: 16, color: Color(0xff424242)), // 텍스트 스타일 변경
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '이름',
              labelStyle: TextStyle(color: Color(0xff424242)), // 레이블 텍스트 스타일 변경
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: '이메일',
              labelStyle: TextStyle(color: Color(0xff424242)), // 레이블 텍스트 스타일 변경
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              String name = _nameController.text;
              String email = _emailController.text;

              String? id = await findId(name, email);
              if (id != null) {
                // 아이디를 찾았을 때의 처리
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('찾은 아이디: $id'),
                    duration: Duration(seconds: 5), // 스낵바 표시 기간 (5초)
                    action: SnackBarAction(
                      label: '확인',
                      onPressed: () {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        // LoginPage()로 이동
                      },
                    ),
                  ),
                );
              } else {
                // 아이디를 찾지 못했을 때의 처리
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('아이디를 찾을 수 없습니다.'),
                    duration: Duration(seconds: 5), // 스낵바 표시 기간 (5초)
                    action: SnackBarAction(
                      label: '확인',
                      onPressed: () {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      },
                    ),
                  ),
                );
              }
            },
            child: Text('아이디 찾기', style: TextStyle(color: Colors.white)), // 버튼 스타일 변경
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xFFFF8C42)), // 버튼 배경색 변경
            ),
          ),
        ],
      ),
    );
  }
}

class ForgotPasswordPage extends StatelessWidget {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            '이름과 가입한 아이디를 입력하세요.',
            style: TextStyle(fontSize: 16, color:Color(0xff424242)), // 텍스트 스타일 변경
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '이름',
              labelStyle: TextStyle(color: Color(0xff424242)), // 레이블 텍스트 스타일 변경
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _idController,
            decoration: InputDecoration(
              labelText: '아이디',
              labelStyle: TextStyle(color: Color(0xff424242)), // 레이블 텍스트 스타일 변경
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              String name = _nameController.text;
              String id = _idController.text;

              String? pw = await findPw(name, id);
              if (pw != null) {
                // 비밀번호를 찾았을 때의 처리
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('찾은 비밀번호: $pw'),
                    duration: Duration(seconds: 5), // 스낵바 표시 기간 (5초)
                    action: SnackBarAction(
                      label: '확인',
                      onPressed: () {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      },
                    ),
                  ),
                );
              } else {
                // 아이디를 찾지 못했을 때의 처리
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('비밀번호를 찾을 수 없습니다.'),
                    duration: Duration(seconds: 5), // 스낵바 표시 기간 (5초)
                    action: SnackBarAction(
                      label: '확인',
                      onPressed: () {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      },
                    ),
                  ),
                );
              }
            },
            child: Text('비밀번호 찾기', style: TextStyle(color: Colors.white)), // 버튼 스타일 변경
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Color(0xFFFF8C42)), // 버튼 배경색 변경
            ),
          ),
        ],
      ),
    );
  }
}
