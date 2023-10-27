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
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyPage(),
    );
  }
}

class MyPage extends StatefulWidget {
  late Map<String, dynamic> data; // 'data' 변수 선언

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {


  late Map<String, dynamic> data;
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
              Container(
                child : Text(data['status'] == 'C' ? '의뢰인' : '전문가'),
                padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              Text(data['nick'], style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
              ElevatedButton(
                onPressed: () {
                  if (data['status'] == 'C') {
                    // 'C'인 경우 전문가로 전환
                    // 전문가로 전환하는 작업 수행
                  } else {
                    // 'C'가 아닌 경우 의뢰인으로 전환
                    // 의뢰인으로 전환하는 작업 수행
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  side: MaterialStateProperty.all(BorderSide(
                    color: Color(0xff424242),
                    width: 0.5,
                  )),
                ),
                child: Text(
                  data['status'] == 'C' ? '전문가로 전환' : '의뢰인으로 전환',
                  style: TextStyle(color: Color(0xff424242)),
                )
              )

            ],
          );
        } else {
          // 데이터를 기다리는 동안에는 로딩 표시나 에러 처리를 할 수 있습니다.
          return CircularProgressIndicator();
        }
      },
    );
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
            onPressed: () {
              // 왼쪽 아이콘을 눌렀을 때 수행할 작업을 여기에 추가합니다.
            },
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
                      margin: EdgeInsets.fromLTRB(10,0,10,5),
                      width: 400,
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
                      padding: const EdgeInsets.all(20.0),
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
                                    side: MaterialStateProperty.all(BorderSide(
                                      color: Color(0xff424242),
                                      width: 0.5,
                                    )),
                                  ),
                                  child: Text(
                                    "프로젝트 의뢰하기",
                                    style: TextStyle(color: Color(0xff424242)),
                                  ),
                                )
                              ],
                            ),
                            margin: EdgeInsets.all(20.0),
                            width: 450,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xfff48752),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          )
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
                          leading: Icon(Icons.star),
                          title: Text('첫 번째 아이템'),
                          subtitle: Text('첫 번째 아이템 설명'),
                          onTap: () {
                            // 첫 번째 아이템이 클릭됐을 때 수행할 작업
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.star),
                          title: Text('두 번째 아이템'),
                          subtitle: Text('두 번째 아이템 설명'),
                          onTap: () {
                            // 두 번째 아이템이 클릭됐을 때 수행할 작업
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.star),
                          title: Text('세 번째 아이템'),
                          subtitle: Text('세 번째 아이템 설명'),
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
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Product()),
                  );
                },
                icon: Icon(Icons.add_circle_outline),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context, MaterialPageRoute(builder: (context) => ChatList()),
                  );
                },
                icon: Icon(Icons.chat_outlined),
              ),
              IconButton(
                onPressed: () async {
                 
                },
                icon: Icon(Icons.person),
              ),
            ],
          ),
        ),
    );
  }

}
