import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/productPayment.dart';
import 'package:project_flutter/join/userModel.dart';
import 'package:provider/provider.dart';

import 'join/login_email.dart';

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
    String user = "";

    UserModel um = Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      user = um.userId!;
      print(user);
    } else {
      user = "없음";
      print("로그인 안됨");
    }

    FirebaseFirestore.instance
        .collection('like')
        .where('user', isEqualTo: user)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "상세보기",
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            tabs: const [
              Tab(text: '상품 상세'),
              Tab(text: '후기'),
            ],
          ),
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

              return Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ClipRRect(
                        child: Image.asset('dog1.PNG'),
                      ),
                     /* Image.network(
                        widget.imageUrl,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),*/
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
                                  CircleAvatar( // 원 모양 프로필 이미지
                                    radius: 40,
                                    backgroundImage: AssetImage('dog4.png'),
                                    /*NetworkImage(userProfileImage),*/
                                  ),
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
                                          child: Text('1:1문의하기'),
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
    return Center(
      child: Text(
        '후기',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}