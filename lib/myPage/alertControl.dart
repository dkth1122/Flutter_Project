import 'package:flutter/material.dart';

class AlertControl extends StatefulWidget {
  const AlertControl({Key? key}) : super(key: key);

  @override
  _AlertControlState createState() => _AlertControlState();
}

class _AlertControlState extends State<AlertControl> {
  bool isPushNotificationEnabled = true; // 푸시 알림 상태 변수
  bool isEmailNotificationEnabled = true; // 이메일 알림 상태 변수
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
          hintStyle: TextStyle(
            color: Color(0xFFFF8C42),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "알림 설정",
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
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text("푸시 알림"),
                subtitle: Text("푸시 알림을 설정합니다."),
                trailing: Switch(
                  value: isPushNotificationEnabled, // 푸시 알림 상태 변수 사용
                  onChanged: (value) {
                    setState(() {
                      isPushNotificationEnabled = value; // 푸시 알림 상태 업데이트
                    });
                  },
                ),
              ),
              ListTile(
                title: Text("이메일 알림"),
                subtitle: Text("이메일 알림을 설정합니다."),
                trailing: Switch(
                  value: true, // 이메일 알림 설정 여부에 따라 변경
                  onChanged: (value) {
                    setState(() {
                      value = !value;
                    });
                  },
                ),
              ),
              // 다른 알림 설정 항목들도 추가할 수 있습니다.
            ],
          ),
        ),
      ),
    );
  }
}
