import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
        primaryColor: Color(0xFF4E598C),
        hintColor: Color(0xFFFCAF58),
        fontFamily: 'Pretendard',
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 16), // 스낵바 내용 텍스트 스타일 변경
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: Colors.black, // 레이블 텍스트의 색상
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4E598C), width: 2.0), // 활성화된 텍스트 필드의 테두리 스타일
            borderRadius: BorderRadius.circular(10.0), // 테두리의 모서리를 둥글게 만듭니다.
          ),
          // 여기에 필요한 다른 스타일을 추가할 수 있습니다.
        ),
      ),

      home: DefaultTabController(
        length: 2, // 탭의 수 (여기서는 2개)
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              '아이디 비밀번호 찾기',
              style: TextStyle(color: Colors.white),
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
              labelColor: Color(0xFF4E598C), // 선택된 탭의 텍스트 컬러
              unselectedLabelColor: Colors.white, // 선택되지 않은 탭의 텍스트 컬러
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF4E598C), // 밑줄의 색상을 변경하려면 여기에서 지정
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
            style: TextStyle(fontSize: 16, color: Colors.black), // 텍스트 스타일 변경
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '이름',
              labelStyle: TextStyle(color: Colors.black), // 레이블 텍스트 스타일 변경
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: '이메일',
              labelStyle: TextStyle(color: Colors.black), // 레이블 텍스트 스타일 변경
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
              backgroundColor: MaterialStateProperty.all(Color(0xFF4E598C)), // 버튼 배경색 변경
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
            style: TextStyle(fontSize: 16, color: Colors.black), // 텍스트 스타일 변경
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: '이름',
              labelStyle: TextStyle(color: Colors.black), // 레이블 텍스트 스타일 변경
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _idController,
            decoration: InputDecoration(
              labelText: '아이디',
              labelStyle: TextStyle(color: Colors.black), // 레이블 텍스트 스타일 변경
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
