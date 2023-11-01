import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/chat/chat.dart';
import 'package:project_flutter/join/userModel.dart';
import 'package:project_flutter/product/productPayment.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../join/login_email.dart';

class ProductView extends StatefulWidget {
  final String productName;
  final String price;
  final String imageUrl;

  const ProductView({
    required this.productName,
    required this.price,
    required this.imageUrl,
  });

  @override
  _ProductViewState createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFavorite = false;
  late Stream<QuerySnapshot>? productStream;
  String chatUser = "";

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    Firebase.initializeApp().then((value) {
      setState(() {
        productStream =
            FirebaseFirestore.instance.collection("product").snapshots();
      });
    });
    String sessionId = "";

    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      sessionId = um.userId!;
      print(sessionId);
    } else {
      sessionId = "";
      print("상품페이지 로그인 안됨");
      print(sessionId);
    }

    FirebaseFirestore.instance
        .collection('like')
        .where('user', isEqualTo: sessionId)
        .where('productName', isEqualTo: widget.productName)
        .get()
        .then((QuerySnapshot snapshot) {
      setState(() {
        _isFavorite = snapshot.docs.isNotEmpty;
      });
    });

    _incrementProductCount();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _incrementProductCount() {
    FirebaseFirestore.instance
        .collection('product')
        .where('pName', isEqualTo: widget.productName)
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((document) {
        final currentCount = document['cnt'] as int;
        document.reference.update({'cnt': currentCount + 1});
      });

      setState(() {
        // UI 업데이트
      });
    });
  }

  void _showLoginAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text('로그인 후 이용 가능한 서비스입니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    ).then((value) {
      if (value != null && value is bool && value) {
        // 로그인 페이지로 이동하는 코드 작성
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });
  }

  void _toggleFavorite() {
    String user = "";
    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      user = um.userId!;
      print(user);
    } else {
      user = "없음";
      print("로그인 안됨");

      // 로그인이 되지 않은 경우에만 알림창 표시 후 함수 종료
      _showLoginAlert(context);

      return;
    }

    FirebaseFirestore.instance
        .collection('like')
        .where('user', isEqualTo: user)
        .where('productName', isEqualTo: widget.productName)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.first.reference.delete().then((value) {
          setState(() {
            _isFavorite = false;
          });
        });
      } else {
        FirebaseFirestore.instance.collection('like').add({
          'user': user,
          'productName': widget.productName,
        }).then((value) {
          setState(() {
            _isFavorite = true;
          });
        });
      }
    });
  }

  void submitReview(int star, String reviewDe, String pName, String user) {
    FirebaseFirestore.instance.collection('review').add({
      'star': star,
      'reviewDe': reviewDe,
      'pName': pName,
      'user': user,
    });
  }

  void _toggleChat() async {
    UserModel userModel = Provider.of<UserModel>(context, listen: false);

    String user = userModel.isLogin ? userModel.userId! : "없음";
    print("채팅유저 ===> $chatUser");

    if (!userModel.isLogin) {
      _showLoginAlert(context);
      return;
    }

    UserModel um = Provider.of<UserModel>(context, listen: false);


    if(chatUser == um.userId.toString()){
      // 본인에게 채팅을 보낼 때 스낵바를 표시
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("본인에게는 채팅을 보낼 수 없습니다."),
      ));
      return;
    }

    // user1과 user2 중에서 큰 값을 선택하여 user1에 할당
    String user1 = user.compareTo(um.userId.toString()) > 0 ? chatUser : um.userId.toString();
    String user2 = user.compareTo(um.userId.toString()) > 0 ? um.userId.toString() : chatUser;

    // Firestore 데이터베이스에 채팅방을 생성하는 함수
    Future<void> createChatRoom(String roomId, String user1, String user2) async {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference chatRoomsCollection = firestore.collection("chat");
      String roomId = '$user1' + '_' + '$user2';

      // 채팅방 ID를 사용하여 Firestore에 채팅방을 추가
      await chatRoomsCollection.doc(roomId).set({
        'user1': user1,
        'user2': user2,
        'roomId' : roomId, // 채팅방 생성 일시
      });
    }

    // 두 사용자 간의 채팅방 ID 확인 및 생성
    String getOrCreateChatRoomId(String user1, String user2) {
      String chatRoomId = '$user1' + '_' + '$user2';
      // Firestore에서 채팅방 ID를 확인하고, 존재하지 않으면 생성
      bool chatRoomExists = false; // Firestore에서 채팅방 존재 여부 확인하는 로직;
      if (!chatRoomExists) {
        // 채팅방이 없다면 생성
        createChatRoom(chatRoomId, user1, user2);
      }
      return chatRoomId;
    }

    void _showPurchaseAlert(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('알림'),
            content: Text('로그인 후 이용 가능한 서비스입니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    }

    //채팅방으로 이동
    void moveToChatRoom(BuildContext context, String chatRoomId) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChatApp(roomId: chatRoomId),
      ));
    }

    //메소드 실행
    String chatRoomId = getOrCreateChatRoomId(user1, user2);
    moveToChatRoom(context, chatRoomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "상세보기",
        ),
        backgroundColor: Color(0xff328772),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            indicatorColor: Color(0xfff48752),
            tabs: const [
              Tab(text: '상품 상세'),
              Tab(text: '후기'),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProductDetailTab(),
                  _buildReviewTab(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 8,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('구매하기'),
                        content: Text('상품 "${widget.productName}"을(를) 구매하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductPayment(
                                    productName: widget.productName,
                                    price: widget.price,
                                    imageUrl : widget.imageUrl,
                                  ),
                                ),
                              );
                            },
                            child: const Text('구매'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xfff48752),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    '구매하기',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: IconButton(
                onPressed: () {
                  _toggleFavorite();
                },
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : null,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetailTab() {
    final formattedPrice = NumberFormat("#,###")
        .format(int.parse(widget.price.replaceAll(',', '')));

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('product').where('pName', isEqualTo: widget.productName).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final productDocs = snapshot.data!.docs;
            if (productDocs.isNotEmpty) {
              final productData = productDocs.first.data() as Map<String, dynamic>;
              final productCount = productData['cnt'] as int;

              // 상품 작성자 정보 가져오기
              final user = productData['user'] as String;

              chatUser = productData['user'] as String;

              return Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.network(
                      widget.imageUrl,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height :20),
                    Text(
                      widget.productName,
                      style :const TextStyle (
                        fontSize :20 ,
                        fontWeight :FontWeight.bold ,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${productData['pDetail']}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height :10),
                    Text (
                      '가격 : $formattedPrice 원',
                      style :const TextStyle (
                        fontSize :16 ,
                      ),
                    ),
                    const SizedBox(height :10),
                    Text (
                      '조회수 : $productCount',
                      style :const TextStyle (
                        fontSize :16 ,
                      ),
                    ),

                    Divider(color :Colors.grey),

                    StreamBuilder<QuerySnapshot>(
                      stream:
                      FirebaseFirestore.instance.collection('userList').where('userId', isEqualTo:user).snapshots(),
                      builder:(context, snapshot){
                        if(snapshot.hasData){
                          final userDocs=snapshot.data!.docs;
                          if(userDocs.isNotEmpty){
                            final userData=userDocs.first.data() as Map<String,dynamic>;
                            /*final userProfileImage=userData['userProfile'] as String;*/
                            final userNick=userData['nick'] as String;

                            return Row(
                              children:[
/*                                CircleAvatar( // 원 모양 프로필 이미지
                                  radius: 40,
                                  backgroundImage: AssetImage('dog4.png'),
                                  *//*NetworkImage(userProfileImage),*//*
                                ),*/
                                SizedBox(width :8),
                                Text(userNick), // 닉네임 출력
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          // 버튼이 클릭되었을 때 실행될 코드 작성
                                          print('버튼이 클릭되었습니다.');
                                        },
                                        child: TextButton(
                                          onPressed: _toggleChat,
                                          child: Text("1:1문의하기"),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            );
                          }
                        }
                        return SizedBox();
                      },
                    ),

                    Divider(color :Colors.grey),

                  ],
                ),);
            }
          }

          return const SizedBox();
        });
  }

  Widget _buildReviewTab() {
    double rating = 0;
    TextEditingController reviewController = TextEditingController();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '후기',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          RatingBar.builder(
            initialRating: rating,
            minRating: 0,
            maxRating: 5,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemSize: 24,
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (newRating) {
              rating = newRating;
            },
          ),
          SizedBox(height: 16),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: reviewController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '후기를 입력해주세요',
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
                  color: Color(0xff328772),
                  onPressed: () {
                    String review = reviewController.text;
                    // 후기 전송 기능 구현
                    // review와 rating을 활용하여 후기 처리
                  },
                ),
              ],
            ),
          ),
          Divider(color :Colors.grey),
        ],
      ),
    );
  }


}