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
  String seller = "";

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
      print(sessionId);
    }

    FirebaseFirestore.instance
        .collection('like')
        .where('user', isEqualTo: sessionId)
        .where('pName', isEqualTo: widget.productName)
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
        seller = document['user'] as String;
        document.reference.update({'cnt': currentCount + 1});
      });

      setState(() {
        // UI 업데이트
      });
    });
  }

  void hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
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
        .where('pName', isEqualTo: widget.productName)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.first.reference.delete().then((value) {
          setState(() {
            _isFavorite = false;
          });

          // 좋아요 삭제 후 product 테이블 업데이트
          FirebaseFirestore.instance
              .collection('product')
              .where('pName', isEqualTo: widget.productName)
              .get()
              .then((QuerySnapshot snapshot) {
            snapshot.docs.forEach((document) {
              final likeCount = document['likeCnt'] as int;
              document.reference.update({'likeCnt': likeCount - 1});
            });
          });
        });
      } else {
        FirebaseFirestore.instance.collection('like').add({
          'user': user,
          'pName': widget.productName,
        }).then((value) {
          setState(() {
            _isFavorite = true;
          });

          // 좋아요 추가 후 product 테이블 업데이트
          FirebaseFirestore.instance
              .collection('product')
              .where('pName', isEqualTo: widget.productName)
              .get()
              .then((QuerySnapshot snapshot) {
            snapshot.docs.forEach((document) {
              final likeCount = document['likeCnt'] as int;
              document.reference.update({'likeCnt': likeCount + 1});
            });
          });
        });
      }
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
    String user1 = chatUser.compareTo(um.userId.toString()) > 0 ? chatUser : um.userId.toString();
    String user2 = chatUser.compareTo(um.userId.toString()) > 0 ? um.userId.toString() : chatUser;

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
          style: TextStyle(
            color: Color(0xff424242),
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom:
        TabBar(
          controller: _tabController,
          labelColor: Color(0xff424242),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFFFCAF58),
          tabs: const [
            Tab(text: '상품 상세'),
            Tab(text: '후기'),
          ],
          onTap: (int index) {
            if (index == 0) {
              // '상품 상세' 탭을 클릭할 때 키보드 숨김
              hideKeyboard();
            }
          },
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Color(0xff424242),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: TabBarView(
          controller: _tabController,
          children: [
            ListView(
              children: [
                SizedBox(height: 20,),
                _buildProductDetailTab(),
              ],
            ),
            ListView(
              children: [
                SizedBox(height: 20,),
                _buildReviewTab(),
              ],
            ),
          ],
        ),
      ),
      extendBody: true, // body를 침범하도록 함
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 300,
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
                                    seller: seller,
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
                  primary: Color(0xFFFCAF58),
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
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
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
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height :10),
                    Text (
                      '가격 : $formattedPrice 원',
                      style :const TextStyle (
                        fontSize :12 ,
                      ),
                    ),
                    const SizedBox(height :10),
                    Text (
                      '조회수 : $productCount',
                      style :const TextStyle (
                        fontSize :12 ,
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
                            final userData = userDocs.first.data() as Map<String,dynamic>;
                            final userProfileImage = userData['profileImageUrl'] as String;
                            final userNick = userData['nick'] as String;

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children:[
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(userProfileImage),
                                ),
                                SizedBox(width: 5),
                                Text(userNick), // 닉네임 출력
                                TextButton(
                                  onPressed: _toggleChat,
                                  child: Text("1:1문의하기"),
                                ),
                              ],
                            );
                          }
                        }
                        return SizedBox();
                      },
                    ),

                    Divider(color :Colors.grey),
                    Text(
                      '취소 및 환불 규정\n\n가. 기본 환불 규정\n1. 전문가와 의뢰인의 상호 협의하에 청약 철회 및 환불이 가능합니다.\n2. 작업이 완료된 이후 또는 자료, 프로그램 등 서비스가 제공된 이후에는 환불이 불가합니다.\n( 소비자보호법 17조 2항의 5조. 용역 또는 「문화산업진흥 기본법」 제2조 제5호의 디지털콘텐츠의 제공이 개시된 경우에 해당) \n \n 나. 전문가 책임 사유 \n1. 전문가의 귀책사유로 당초 약정했던 서비스 미이행 혹은 보편적인 관점에서 심각하게 잘못 이행한 경우 결제 금액 전체 환불이 가능합니다. \n\n 다. 의뢰인 책임 사유 \n1. 서비스 진행 도중 의뢰인의 귀책사유로 인해 환불을 요청할 경우, 사용 금액을 아래와 같이 계산 후 총 금액의 10%를 공제하여 환불합니다.\n총 작업량의 1/3 경과 전 : 이미 납부한 요금의 2/3해당액\n총 작업량의 1/2 경과 전 : 이미 납부한 요금의 1/2해당액\n총 작업량의 1/2 경과 후 : 반환하지 않음',
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
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

    UserModel um = Provider.of<UserModel>(context, listen: false);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '후기',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('review')
                .where('pName', isEqualTo: widget.productName)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final reviews = snapshot.data!.docs;
                if (reviews.isNotEmpty) {
                  double totalRating = 0;
                  for (var review in reviews) {
                    totalRating += review['star'];
                  }
                  double averageRating = totalRating / reviews.length;
                  return Text(
                    '(★ ${averageRating.toStringAsFixed(1)})',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  );
                }
              }
              return SizedBox();
            },
          ),
          SizedBox(height: 16),
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
          um.isLogin
              ? Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
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
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.send),
                      color: Color(0xFFFCAF58),
                      onPressed: () {
                        String review = reviewController.text;
                        FirebaseFirestore.instance
                            .collection('orders')
                            .where('productName', isEqualTo: widget.productName)
                            .where('user', isEqualTo: um.userId)
                            .get()
                            .then((snapshot) {
                          if (snapshot.docs.isNotEmpty) {
                            submitReview(rating.toInt(), review, widget.productName, um.userId!);
                          } else {
                            _showPurchaseAlert(context);
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],
          )
              : Text(
            '상품을 구매한 경우에만 후기 등록 가능합니다.',
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('review')
                .where('pName', isEqualTo: widget.productName)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final reviews = snapshot.data!.docs;
                if (reviews.isEmpty) {
                  return Text('아직 등록된 후기가 없습니다.');
                } else {
                  return Column(
                    children: reviews.map((review) {
                      final starRating = review['star'];
                      final userId = review['userId'];
                      final reviewContent = review['rContent'];

                      String starString = '';
                      for (int i = 0; i < 5; i++) {
                        if (i < starRating) {
                          starString += '★';
                        } else {
                          starString += '☆';
                        }
                      }

                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  starString,
                                  style: TextStyle(fontSize: 24),
                                ),
                                SizedBox(width: 16),
                                Text(userId),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(reviewContent),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
    );
  }


  void submitReview(int star, String reviewDe, String pName, String user) {
    FirebaseFirestore.instance.collection('review').add({
      'star': star,
      'rContent': reviewDe,
      'pName': pName,
      'userId': user,
    });
  }

  void _showPurchaseAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('알림'),
          content: Text('상품을 구매한 경우에만 후기 등록 가능합니다.'),
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



}