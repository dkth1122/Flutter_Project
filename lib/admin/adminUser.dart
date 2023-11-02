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
  late TextEditingController searchUser = TextEditingController();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().then((value) {
      setState(() {
        userListStream = FirebaseFirestore.instance.collection('userList')
            .where('name', isNotEqualTo: '관리자계정')
            .orderBy('name')
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchUser,
              decoration: InputDecoration(
                hintText: '유저의 ID를 입력하세요',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    String searchKeyword = searchUser.text.trim();
                    print(searchKeyword);
                    print('검색어: $searchKeyword');
                    setState(() {
                      userListStream = FirebaseFirestore.instance.collection('userList')
                          .where('userId', isGreaterThanOrEqualTo: searchKeyword)
                          .where('userId', isLessThan: searchKeyword + 'z')
                          .orderBy('userId')
                          .snapshots();
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: userListStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('데이터를 불러오는 중에 오류가 발생했습니다.'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('해당 검색어에 해당하는 회원이 없습니다.'));
                } else {
                  return ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                String userId = document.id;
                String uId = data['userId'];
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
                    children: [
                      Text(name, style: TextStyle(color: Colors.black)),
                      Text(' ($nick)', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  subtitle: Text(userId),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_red_eye),
                    onPressed: () {
                      AdminUserView user = AdminUserView(
                        userId,
                        uId,
                        name,
                        nick,
                        email,
                        birth,
                        cdatetime,
                        banYn,
                        delYn,
                        status,
                      );
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
          ),
        ],
      ),
    );
  }
}