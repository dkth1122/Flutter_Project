import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AdminUser extends StatefulWidget {
  @override
  State<AdminUser> createState() => _AdminUserState();
}

class _AdminUserState extends State<AdminUser> {
  late Stream<QuerySnapshot> userListStream;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().then((value) {
      setState(() {
        userListStream = FirebaseFirestore.instance.collection('userList').snapshots();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원 관리'),
        backgroundColor: Color(0xFF4E598C),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userListStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('데이터를 불러오는 중에 오류가 발생했습니다.'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('회원이 없습니다.'));
          } else {
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                String userId = document.id;
                String name = data['name'] ?? '이름 없음';
                String nick = data['nick'] ?? ''; // nick 값이 없으면 빈 문자열 반환

                return ListTile(
                  title: Row(
                    children: <Widget>[
                      Text(name, style: TextStyle(color: Colors.black)), // name은 검정색
                      Text(' ($nick)', style: TextStyle(color: Colors.grey)), // (nick)은 회색
                    ],
                  ),
                  subtitle: Text(userId),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
