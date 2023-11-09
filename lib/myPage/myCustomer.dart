import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/expert/my_expert.dart';
import 'package:project_flutter/main.dart';
import 'package:project_flutter/myPage/myCoupon.dart';
import 'package:project_flutter/proposal/myProposal.dart';
import 'package:project_flutter/myPage/purchaseManagement.dart';
import 'package:project_flutter/subBottomBar.dart';
import 'package:provider/provider.dart';
import '../join/userModel.dart';
import '../proposal/myProposalList.dart';
import '../proposal/myProposalView.dart';
import 'editProfile.dart';

class MyCustomer extends StatefulWidget {
  final String userId;

  const MyCustomer({required this.userId, Key? key}) : super(key: key);

  @override
  _MyCustomerState createState() => _MyCustomerState(userId: userId);
}

class _MyCustomerState extends State<MyCustomer> {
  final String userId;
  late Map<String, dynamic> data;
  String profileImageUrl = '';

  _MyCustomerState({required this.userId});

  @override
  void initState() {
    super.initState();
    loadUserProfileImageUrl();
  }

  void loadUserProfileImageUrl() async {
    String? imageUrl = await getUserProfileImageUrl(userId);
    setState(() {
      profileImageUrl = imageUrl ?? 'assets/profile.png';
    });
  }

  Future<String?> getUserProfileImageUrl(String userId) async {
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
  Widget _MyProposalFirst() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("proposal")
          .where("user", isEqualTo: userId)
          .limit(1) // 최신 데이터 1개만 가져옴
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snap.data!.docs.isEmpty) {
          return Text("아직 제안서가 없습니다.");
        }

        DocumentSnapshot doc = snap.data!.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Color(0xff424242), // 원하는 테두리 색상 설정
            ),
            borderRadius: BorderRadius.circular(8.0), // 원하는 모서리 둥글기 설정
          ),
          child: Column(
            children: [
              SizedBox(height: 10,),
              ListTile(
                title: Text.rich(
                  TextSpan(
                    text: "${data["title"]}",
                    style: TextStyle(
                      fontSize: 24, // 큰 글자 크기
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF424242), // 색상 설정
                      decoration: data['delYn'] == 'Y' ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: [
                    SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "받은 제안 수: ${data["accept"].toString()}건", // 큰 글자 크기
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff424242), // 글자 색상 설정
                            decoration: TextDecoration.underline, // 밑줄 추가
                            decorationColor: Color(0xFFFF9C784), // 밑줄 색상 설정
                          ),
                        ),

                        Text(
                          "예산: ${data["price"].toString()}", // 큰 글자 크기
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFCAF58), // 색상 설정
                          ),
                        ),
                      ],
                    ),
                    Text(
                      data["category"],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white, // 색상 설정
                      ),
                    ),
                    Text(
                      data["content"],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey, // 색상 설정
                      ),
                    ),
                    SizedBox(height: 5,)
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF424242), // 화살표 아이콘의 색상 설정
                  size: 32, // 아이콘의 크기 설정
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyProposalView(
                        user: widget.userId,
                        proposalTitle: data["title"],
                        proposalContent: data["content"],
                        proposalPrice: data["price"],
                        proposalDel: data['delYn'],
                      ),
                    ),
                  );
                },
              )

            ],
          ),
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "마이페이지",
          style: TextStyle(color:Color(0xff424242), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 1.0,
        iconTheme: IconThemeData(color: Color(0xff424242)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            child: Text(
              "계정 설정",
              style: TextStyle(
                color : Color(0xff424242),
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
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyCoupon()));
            },
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("5장", style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),),
                  SizedBox(height: 5,),
                  Divider(),
                  Text("할인 쿠폰", style: TextStyle(fontSize:18, color: Colors.grey, fontWeight: FontWeight.bold),)
                ],
              ),
                margin: EdgeInsets.fromLTRB(10, 0, 10, 5),
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
          ),
            Divider(
              color: Colors.grey,
              thickness: 5.0,
            ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "내 프로젝트",
                        style: TextStyle(fontSize: 24),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyProposalList(userId: userId)),
                          );
                        },
                        child: Text("전체보기",style: TextStyle(color: Color(0xff424242), fontSize: 18),),
                      ),
                    ],
                ),
                  _MyProposalFirst(),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          subtitle: Text("요구사항을 작성하시고, 딱 맞는 전문가와의 거래를 진행하세요"),
                          title: Row(
                            children: [
                              Icon(Icons.note_add_outlined),
                              Text(
                                "프로젝트 의뢰하기",
                                style: TextStyle(
                                  fontSize: 18,  // 텍스트 크기 늘리기
                                  fontWeight: FontWeight.bold,  // 글꼴 두껍게 설정
                                  color: Color(0xff424242),  // 원하는 색상으로 설정
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => MyProjectProposal()),
                            );
                          },
                        ),
                      ],
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
                    Navigator.push(context, MaterialPageRoute(builder: (context) => PurchaseManagement(userId:userId)));
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
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SubBottomBar(),
    );
  }

  Widget _userInfo() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("userList")
          .where("userId", isEqualTo: widget.userId)
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
                      '의뢰인',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    data['nick'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  UserModel userModel = Provider.of<UserModel>(context, listen: false);
                  userModel.updateStatus('E');

                  CollectionReference users = FirebaseFirestore.instance.collection('userList');
                  users
                      .where('userId', isEqualTo: widget.userId)
                      .limit(1)
                      .get()
                      .then((QuerySnapshot querySnapshot) {
                    if (querySnapshot.docs.isNotEmpty) {
                      DocumentReference docRef = querySnapshot.docs.first.reference;
                      Map<String, dynamic> dataToUpdate = {
                        'status': 'E',
                      };
                      docRef.update(dataToUpdate).then((_) {
                        print("문서 업데이트 성공");
                      }).catchError((error) {
                        print("문서 업데이트 오류: $error");
                      });
                    }
                  });
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyExpert(userId: userId),
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
                  '전문가로 전환',
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
