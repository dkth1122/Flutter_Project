import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/productPayment.dart';
import 'package:project_flutter/join/userModel.dart';
import 'package:provider/provider.dart';

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

    // 'like' 컬렉션에서 해당 유저(user)와 상품명(productName)을 가지는 문서를 조회하여 _isFavorite 값을 설정합니다.
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    }

    // 'like' 컬렉션에서 해당 유저(user)와 상품명(productName)을 가지는 문서를 조회합니다.
    FirebaseFirestore.instance
        .collection('like')
        .where('user', isEqualTo: user)
        .where('productName', isEqualTo: widget.productName)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        // 이미 좋아요가 눌려있는 경우, 해당 문서를 삭제합니다.
        snapshot.docs.first.reference.delete().then((value) {
          setState(() {
            _isFavorite = false;
          });
        });
      } else {
        // 좋아요가 눌려있지 않은 경우, 'like' 컬렉션에 새로운 문서를 추가합니다.
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
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductDetailTab(),
                _buildReviewTab(),
              ],
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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            widget.imageUrl,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 20),
          Text(
            widget.productName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '가격: $formattedPrice 원',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
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
