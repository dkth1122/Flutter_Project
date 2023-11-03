import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'adminUserView.dart';

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
        userListStream = FirebaseFirestore.instance.collection('userList')
            .where('name', isNotEqualTo: '관리자계정') // '관리자계정'인 경우 제외
            .orderBy('name') // 이름(name) 기준으로 오름차순 정렬
            .snapshots();
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
                String nick = data['nick'] ?? '';
                String email = data['email'];
                String birth = data['birth'];
                Timestamp timestamp = data['cdatetime'];
                String cdatetime = timestamp.toDate().toString();
                String banYn = data['banYn'];
                String delYn = data['delYn'];
                String status = data['status'];

                return ListTile(
                  title: Row(
                    children: <Widget>[
                      Text(name, style: TextStyle(color: Colors.black)),
                      Text(' ($nick)', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  subtitle: Text(userId),
                  trailing: IconButton(
                    icon: Icon(Icons.search_outlined),
                    onPressed: () {
                      AdminUserView user = AdminUserView(userId, name, nick, email, birth, cdatetime, banYn, delYn, status,);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminUserViewPage(user: user),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
