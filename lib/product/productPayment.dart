import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/join/userModel.dart';
import 'package:provider/provider.dart';

import '../join/login_email.dart';

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
  String selectedCoupon = '--------------------';
  double discountPercentage = 0.0;
  int discountedPrice = 0;

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
    UserModel um = Provider.of<UserModel>(context, listen: false);
    String user = um.isLogin ? um.userId! : "없음";

    return Scaffold(
      appBar: AppBar(
        title: const Text('결제 페이지'),
        backgroundColor: Color(0xff328772),
      ),
      body: Center(
    child: user == "없음" || user == null
    ? Column(
    mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '로그인 후 이용해주세요.',
          style: const TextStyle(fontSize: 16),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
          child: const Text('로그인 하러 가기'),
          style: ElevatedButton.styleFrom(
            primary: Color(0xfff48752),
          ),
        ),
      ],
    )
        : Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          '${widget.productName}',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 10),
        Text(
          '상품가: ${NumberFormat('###,###').format(int.parse(widget.price))}원',
          style: const TextStyle(fontSize: 16),
        ),
        Divider(color: Colors.grey),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Text(
                '할인 쿠폰: ',
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(width: 8.0),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('coupon').where('userId', isEqualTo: user).get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final coupons = snapshot.data!.docs;
                  return DropdownButton<String>(
                    value: selectedCoupon,
                    items: [
                      DropdownMenuItem<String>(
                        value: '--------------------',
                        child: Text('--------------------'),
                      ),
                      ...coupons.map((coupon) {
                        return DropdownMenuItem<String>(
                          value: coupon['cName'],
                          child: Text(coupon['cName']),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCoupon = value!;
                        if (value == '--------------------') {
                          discountPercentage = 0.0;
                        } else {
                          final selectedCouponData = coupons.firstWhere((coupon) => coupon['cName'] == value);
                          discountPercentage = (int.parse(widget.price) / 100) * (selectedCouponData['discount']).toDouble();
                          calculateDiscountedPrice();
                        }
                      });
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('데이터를 가져오는 동안 오류가 발생했습니다.');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            '상품가: ${NumberFormat('###,###').format(int.parse(widget.price))}원  할인가: ${NumberFormat('###,###').format(discountPercentage)}원 ',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
        Center(
          child: Text(
            '총 ${NumberFormat('###,###').format(int.parse(widget.price) - discountPercentage)}원',
            style: const TextStyle(fontSize: 30),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 10), // 마진 추가
        Divider(color: Colors.grey),
        Center(
          child: ElevatedButton(
            onPressed: () {
              // TODO: 결제 처리를 위한 함수 호출 또는 네비게이션 추가
            },
            child: Text(
              '결제하기',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              primary: Color(0xfff48752),
            ),
          ),
        ),
      ],
    ),
      ),
    );
  }

  void calculateDiscountedPrice() { // 할인된 가격 결제시 넘길 금액
    discountedPrice = int.parse(widget.price) - discountPercentage.toInt();
    print(discountedPrice);
  }
}