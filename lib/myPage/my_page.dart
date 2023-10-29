import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/myPage/editProfile.dart';
import 'package:provider/provider.dart';
import '../chat/chatList.dart';
import '../firebase_options.dart';
import '../join/userModel.dart';
import '../product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyPage(),
      ),
    ),
  );
}

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late Map<String, dynamic> data;
  late bool isExpert;

  @override
  void initState() {
    super.initState();
    isExpert = false;
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
          isExpert = data['status'] == 'E';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isExpert ? '전문가' : '의뢰인',
                    style: TextStyle(
                      backgroundColor: Colors.yellow,
                      // borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  Text(
                    data['nick'],
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  _toggleExpertStatus();
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
                  data['status'] == 'C' ? '전문가로 전환' : '의뢰인으로 전환',
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

  void _toggleExpertStatus() {
    String newStatus = isExpert ? 'C' : 'E';

    FirebaseFirestore.instance
        .collection("userList")
        .where('userId', isEqualTo: data['userId'])
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({'status': newStatus}).then((_) {
          setState(() {
            isExpert = !isExpert;
          });
        }).catchError((error) {
          print('Firestore 업데이트 실패: $error');
        });
      });
    }).catchError((error) {
      print('Firestore 쿼리 실패: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "마이페이지",
          style: TextStyle(color: Colors.grey),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: IconThemeData(color: Colors.grey),
        leading: IconButton(
          icon: Icon(Icons.add_alert),
          onPressed: () {},
        ),
        actions: [
          TextButton(
            child: Text(
              "계정 설정",
              style: TextStyle(color: Colors.grey),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfile(data: data),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile.png'),
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
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Text("내 프로젝트", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Container(
                    child: Column(
                      children: [
                        Text("요구사항을 작성하시고, 딱 맞는 전문가와의 거래를 진행하세요"),
                        ElevatedButton(
                          onPressed: () {},
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
                            "프로젝트 의뢰하기",
                            style: TextStyle(color: Color(0xff424242)),
                          ),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.all(20.0),
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 5.0,
            ),
            ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  leading: Icon(Icons.shopping_bag_outlined),
                  title: Text('구매관리'),
                  trailing: Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {
                    // 첫 번째 아이템이 클릭됐을 때 수행할 작업
                  },
                ),
                ListTile(
                  leading: Icon(Icons.credit_card),
                  title: Text('결제/환불내역'),
                  trailing: Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {
                    // 두 번째 아이템이 클릭됐을 때 수행할 작업
                  },
                ),
                ListTile(
                  leading: Icon(Icons.question_mark),
                  title: Text('고객센터'),
                  trailing: Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {
                    // 세 번째 아이템이 클릭됐을 때 수행할 작업
                  },
                ),
                ListTile(
                  leading: Icon(Icons.star),
                  title: Text('네 번째 아이템'),
                  subtitle: Text('네 번째 아이템 설명'),
                  onTap: () {
                    // 네 번째 아이템이 클릭됐을 때 수행할 작업
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 5.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Product()),
                );
              },
              icon: Icon(Icons.shopping_bag_outlined),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatList()),
                );
              },
              icon: Icon(Icons.chat_outlined),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.person_outline),
            ),
          ],
        ),
      ),
    );
  }
}
