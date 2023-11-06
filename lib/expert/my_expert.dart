import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/expert/ratings.dart';
import 'package:project_flutter/expert/revenue.dart';
import 'package:project_flutter/myPage/myCustomer.dart';
import 'package:provider/provider.dart';

import '../join/userModel.dart';
import '../myPage/customerLike.dart';
import '../myPage/editProfile.dart';
import 'messageResponse.dart';
import 'myPortfolio.dart';

class MyExpert extends StatefulWidget {
  final String userId;

  const MyExpert({required this.userId, Key? key}) : super(key: key);
  @override
  State<MyExpert> createState() => _MyExpertState(userId: userId);
}

class _MyExpertState extends State<MyExpert> {
  late final String userId;
  late Map<String, dynamic> data;
  String profileImageUrl = '';

  _MyExpertState({required this.userId});

  @override
  void initState() {
    super.initState();
    loadUserProfileImageUrl(); // 프로필 이미지 URL을 로드
  }

  void loadUserProfileImageUrl() async {
    String? imageUrl = await getUserProfileImageUrl(userId);
    setState(() {
      profileImageUrl = imageUrl ?? 'assets/profile.png';
    });
  }

  Future<String?> getUserProfileImageUrl(String userId) async {
    try {
      UserModel userModel = Provider.of<UserModel>(context);
      CollectionReference users = FirebaseFirestore.instance.collection("userList");
      QuerySnapshot snap = await users.where('userId', isEqualTo: userModel.userId).get();

      for (QueryDocumentSnapshot doc in snap.docs) {
        return doc['profileImageUrl'] as String?;
      }
    } catch (e) {
      return null;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "마이페이지",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF4E598C),
        elevation: 1.0,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            child: Text(
              "계정 설정",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfile(data: data), // EditProfile 위젯을 제공
                ),
              );

            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _userInfo(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 5.0,
            ),


            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '보낸 제안',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  // 작업 가능한 프로젝트 목록
                  // 프로젝트 보러가기 버튼
                ],
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 5.0,
            ),

            // 판매 정보 섹션
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '판매 정보',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '3개월 이내 판매중인 건수:',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    '50',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue, // 파란색 텍스트
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 5.0,
            ),
            // 나의 서비스 섹션
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '나의 서비스',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ListTile(
                    leading: Icon(Icons.monetization_on), // 아이콘 추가
                    title: Text(
                      '수익 관리',
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) => Revenue()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.star), // 아이콘 추가
                    title: Text(
                      '나의 전문가 등급',
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ExpertRating()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.portrait), // 아이콘 추가
                    title: Text(
                      '나의 포트폴리오',
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) => Portfolio()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.message), // 아이콘 추가
                    title: Text(
                      '메시지 응답 관리',
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) => MessageResponse()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userInfo() {
    UserModel userModel = Provider.of<UserModel>(context);

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("userList")
          .where("userId", isEqualTo: userModel.userId)
          .limit(1)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (snap.hasData) {
          data = snap.data!.docs[0].data() as Map<String, dynamic>;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '전문가',
                    style: TextStyle(
                      backgroundColor: Colors.yellow,
                    ),
                  ),
                  Text(
                    data['nick'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: (){
                  UserModel userModel = Provider.of<UserModel>(context, listen: false);
                  userModel.updateStatus('C');
                  // Firestore 컬렉션 "userList"에서 userId와 userModel.userId가 일치하는 문서를 찾습니다.
                  CollectionReference users = FirebaseFirestore.instance.collection('userList');
                  users
                      .where('userId', isEqualTo: userModel.userId)
                      .limit(1)
                      .get()
                      .then((QuerySnapshot querySnapshot) {
                    if (querySnapshot.docs.isNotEmpty) {
                      // userId와 userModel.userId가 일치하는 문서가 존재하면 해당 문서를 업데이트합니다.
                      DocumentReference docRef = querySnapshot.docs.first.reference;
                      // 업데이트할 데이터
                      Map<String, dynamic> dataToUpdate = {
                        'status': 'C',
                      };
                      docRef.update(dataToUpdate).then((_) {
                        print("문서 업데이트 성공");
                        // 업데이트 성공 후, 원하는 작업을 수행할 수 있습니다.
                      }).catchError((error) {
                        print("문서 업데이트 오류: $error");
                        // 업데이트 오류 처리
                      });
                    }
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyCustomer(userId: userModel.userId!),
                    ),
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  side: MaterialStateProperty.all(
                    BorderSide(
                      color: Color(0xff424242),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Text(
                  '의뢰인으로 전환',
                  style: TextStyle(color: Color(0xff424242)),
                ),
              ),
            ],
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
