import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/join/userModel.dart';
import 'package:provider/provider.dart';

class ProductPayment extends StatefulWidget {
  final String productName;
  final String price;

  const ProductPayment({
    required this.productName,
    required this.price,
  });

  @override
  State<ProductPayment> createState() => _ProductPaymentState();
}

class _ProductPaymentState extends State<ProductPayment> {

  late Stream<QuerySnapshot>? productStream;

  @override
  void initState() {
    super.initState();


    Firebase.initializeApp().then((value) {
      setState(() {
        productStream = FirebaseFirestore.instance.collection("product").snapshots();
      });
    });
    String user = "";

    UserModel um =Provider.of<UserModel>(context, listen: false);

    if (um.isLogin) {
      // 사용자가 로그인한 경우
      user = um.userId!;
      print(user);

    } else {
      // 사용자가 로그인하지 않은 경우
      user = "없음";
      print("로그인 안됨");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('결제 페이지'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '상품명: ${widget.productName}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              '가격: ${widget.price} 원',
              style: const TextStyle(fontSize: 16),
            ),
            // ... 결제 페이지의 내용 추가 ...
          ],
        ),
      ),
    );
  }
}
