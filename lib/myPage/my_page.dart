import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/expert/my_expert.dart';
import 'package:project_flutter/myPage/myCustomer.dart';
import 'package:provider/provider.dart';
import '../bottomBar.dart';
import '../join/userModel.dart';
import 'editProfile.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late Map<String, dynamic> data;
  bool isExpert = true;
  late Color appBarColor;

  @override
  void initState() {
    super.initState();
    _updateAppBarColor(); // 페이지가 열릴 때 바로 appBarColor를 업데이트합니다.
  }
  void _updateAppBarColor() {
    if (isExpert) {
      appBarColor = Color(0xFFFCAF58);
    } else {
      appBarColor = Color(0xFF4E598C);
    }
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
          _updateAppBarColor();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isExpert ? '전문가' : '의뢰인',
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
                onPressed: _toggleExpertStatus,
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
    final newStatus = isExpert ? 'C' : 'E';

    FirebaseFirestore.instance
        .collection("userList")
        .where('userId', isEqualTo: data['userId'])
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({'status': newStatus}).then((_) {
          setState(() {
            isExpert = !isExpert;
            _updateAppBarColor();
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
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Pretendard',
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "마이페이지",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: appBarColor,
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

              if(isExpert)
                MyCustomer(),
              if(!isExpert)
                MyExpert()
            ],
          ),
        ),
        bottomNavigationBar: BottomBar(),
      ),
    );
  }
}
