import 'package:flutter/material.dart';
import 'package:project_flutter/myPage/userData.dart';

class EditProfile extends StatefulWidget {
  final UserData? userData; // 생성자에서 데이터 받기

  EditProfile({required this.userData}); // 생성자 업데이트

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "계정 설정",
            style: TextStyle(color: Colors.grey),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1.0,
          iconTheme: IconThemeData(color: Colors.grey),
          leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Colors.grey,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.info_outline_rounded),
              onPressed: () {
                // 오른쪽 아이콘을 눌렀을 때 수행할 작업을 여기에 추가합니다.
              },
            ),
          ],
        ),

        body: Container(
          child: Text(widget.userData?.name ?? '사용자 ID가 없습니다.'),
        ),
      ),
    );
  }
}