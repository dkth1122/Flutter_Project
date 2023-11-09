import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/chat/chatList.dart';
import 'package:project_flutter/expert/ratings.dart';
import 'package:project_flutter/expert/revenue.dart';
import 'package:project_flutter/expert/salesManagement.dart';
import 'package:project_flutter/myPage/myCustomer.dart';
import 'package:provider/provider.dart';
import '../join/userModel.dart';
import '../myPage/editProfile.dart';
import '../proposal/myProposalList.dart';
import '../proposal/proposalList.dart';
import '../subBottomBar.dart';
import 'messageResponse.dart';
import 'myPortfolio.dart';

class MyExpert extends StatefulWidget {
  final String userId;

  const MyExpert({required this.userId, Key? key}) : super(key: key);

  @override
  State<MyExpert> createState() => _MyExpertState(userId: userId);
}

class _MyExpertState extends State<MyExpert> {
  final String userId;
  late Map<String, dynamic> data;
  String profileImageUrl = '';

  //등급용
  String user = '';
  String expertRating = 'New'; // 기본 등급
  int documentCount = 0;
  num totalAmount = 0;

  String rating = "";


  _MyExpertState({required this.userId});

  @override
  void initState() {
    super.initState();
    loadExpertProfileImageUrl(); // 프로필 이미지 URL을 로드

    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      user = um.userId!;
      calculateExpertRating(user).then((rating) {
        setState(() {
          expertRating = rating;
        });
      });
    } else {
      user = '없음';
      print('로그인 X');
    }
  }

  void loadExpertProfileImageUrl() async {
    String? imageUrl = await getExpertProfileImageUrl(userId);
    setState(() {
      profileImageUrl = imageUrl ?? 'assets/profile.png';
    });
  }

  Future<String?> getExpertProfileImageUrl(String userId) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection("userList");
      QuerySnapshot snap = await users.where('userId', isEqualTo: userId).get();

      for (QueryDocumentSnapshot doc in snap.docs) {
        return doc['profileImageUrl'] as String?;
      }
    } catch (e) {
      return null;
    }
  }

  //등급 출력용
  Future<String> calculateExpertRating(String userId) async {
    // Firebase.initializeApp()를 호출하지 않고 이미 초기화되었다고 가정하고 진행
    final firestore = FirebaseFirestore.instance;

    // Calculate the total order amount for the user
    QuerySnapshot querySnapshot = await firestore
        .collection('orders')
        .where('seller', isEqualTo: userId)
        .get();

    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      totalAmount += document['price'];
    }

    //문서가 총 몇개 있는지
    documentCount = querySnapshot.size;

    // Determine the expert rating based on the total order amount
    rating = 'New 🌱';

    if (documentCount >= 1 || totalAmount >= 5000) {
      setState(() {
        rating = 'LEVEL 1 🍀';
      });
    }

    if (documentCount >= 15 || totalAmount >= 5000000) {
      setState(() {
        rating = 'LEVEL 2 🌷';
      });
    }

    if (documentCount >= 100 || totalAmount >= 20000000) {
      setState(() {
        rating = 'LEVEL 3 🌺';
      });
    }

    if (documentCount >= 300 || totalAmount >= 80000000) {
      setState(() {
        rating = 'MASTER 💐';
      });
    }

    DocumentReference userDocumentRef = firestore.collection('rating').doc(userId);

    if (userDocumentRef != null) {
      // 이미 해당 사용자의 문서가 존재하는 경우, "set"을 사용하여 업데이트
      userDocumentRef.set({
        'user': userId,
        'rating': rating,
      });
    } else {
      // 해당 사용자의 문서가 없는 경우, "add"를 사용하여 새로운 문서 추가
      firestore.collection('rating').add({
        'user': userId,
        'rating': rating,
      });
    }
    return rating;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "마이페이지",
          style: TextStyle(color: Color(0xff424242), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Color(0xff424242),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
          color: Color(0xFFFF8C42),
            icon: Icon(Icons.settings),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("내 등급", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey,),),
                  SizedBox(height: 5,),
                  Divider(thickness: 1,),
                  Text("$rating", style: TextStyle(fontSize:23, fontWeight: FontWeight.bold, color: Color(0xff424242)),)
                ],
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
                  Text(
                    "보낸제안",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    child: Column(
                      children: [
                        Text("작업 가능한 프로젝트를 확인하시고 금액을 제안해 주세요."),
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context)=>ProposalList()));
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
                                "프로젝트 보러가기",
                                style: TextStyle(color: Color(0xff424242)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    margin: EdgeInsets.all(20.0),
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

            // 판매 정보 섹션
            Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 오른쪽 끝에 버튼 배치
                    children: <Widget>[
                      Text(
                        '판매 정보',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context)=>SalesManagementPage(userId:userId)));
                        },
                        child: Text(
                          '전체보기',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue, // 파란색 텍스트
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    '3개월 이내 판매 중인 건수:',
                    style: TextStyle(fontSize: 18),
                  ),
                  FutureBuilder<int>(
                    future: getProductCount(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        int productCount = snapshot.data ?? 0;
                        return Text(
                          '$productCount',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        );
                      }
                    },
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
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
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
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
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
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) => Portfolio()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.question_answer), // 아이콘 추가
                    title: Text(
                      '메시지 응답 관리',
                    ),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) => MessageResponse()));
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.chat_outlined),
                    title: Text("나의 대화 목록"),
                    trailing: Icon(Icons.arrow_forward_ios_rounded),
                    onTap: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatList()));
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SubBottomBar(),
    );
  }

  Future<int> getProductCount(String userId) async {
    try {
      CollectionReference products = FirebaseFirestore.instance.collection('product');
      QuerySnapshot querySnapshot = await products.where('user', isEqualTo: userId).get();
      int productCount = querySnapshot.size;
      return productCount;
    } catch (e) {
      print('Error retrieving product count: $e');
      return 0; // Return a default value (0) when an error occurs.
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(4.0), // 원하는 패딩 설정
                    decoration: BoxDecoration(
                      color: Colors.yellow, // 배경색 설정
                      borderRadius: BorderRadius.circular(8.0), // 보더를 둥글게 만듦
                    ),
                    child: Text(
                      '전문가',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:  Color(0xff424242),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    data['nick'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff424242)),
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
                  backgroundColor: MaterialStateProperty.all(Color(0xFFFF8C42)),
                ),
                child: Text(
                  '의뢰인으로 전환',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
