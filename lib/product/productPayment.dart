import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/join/userModel.dart';
import 'package:project_flutter/product/payment.dart';
import 'package:provider/provider.dart';

import '../join/login_email.dart';

class ProductPayment extends StatefulWidget {
  final String productName;
  final String price;
  final String imageUrl;
  final String seller; // 사용자 정보 추가

  const ProductPayment({
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.seller
  });

  @override
  State<ProductPayment> createState() => _ProductPaymentState();
}

class _ProductPaymentState extends State<ProductPayment> {

  late Stream<QuerySnapshot>? productStream;
  String selectedCoupon = '--------------------';
  double discountPercentage = 0.0;
  int discountedPrice = 0;
  bool agreedToTerms = false;
  int totalPrice = 0;

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
        backgroundColor: Color(0xFF4E598C),
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
            primary: Color(0xFFFCAF58),
          ),
        ),
      ],
    )
        : Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.network(
          widget.imageUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
        const SizedBox(height :20),
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
                          totalPrice = calculateDiscountedPrice();
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
            style: const TextStyle(fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
        Center(
          child: Text(
            '총 ${NumberFormat('###,###').format(int.parse(widget.price) - discountPercentage)}원',
            style: const TextStyle(fontSize: 25),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 10), // 마진 추가
        Divider(color: Colors.grey),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 150,
                child: ListView.builder(
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 150,
                      child: SingleChildScrollView(
                        child: Text(
                          '환불 규정 유의사항 동의\n· 전문가가 의뢰인의 주문 의뢰 내용에 맞게 용역을 제공하는 맞춤형 상품의 경우, 가분하거나 재판매하기 어려운 성격의 상품입니다. 주문 의뢰 내용에 따라 용역 등의 작업이 진행된 이후에는 「전자상거래법」 제17조 2항에 따라 원칙적으로 청약철회가 제한됩니다. 의뢰인은 서비스 상세페이지에 명시된 취소·환불 규정 또는 전문가와 별도 합의한 내용에 따라 청약철회를 요청할 수 있습니다.\n· 디지털 형태로 제작된 콘텐츠를 제공하는 상품의 경우, 콘텐츠 제공이 개시되면 서비스 제공이 완료된 것으로 간주합니다. 콘텐츠 제공이 개시된 이후에는 「전자상거래법」 제17조 2항에 따라 원칙적으로 청약철회가 제한됩니다. 의뢰인은 서비스 상세페이지에 등록된 디지털 콘텐츠의 일부를 미리 확인한 후 서비스를 구매할 수 있습니다.',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    agreedToTerms = !agreedToTerms;
                  });
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('위 내용을 확인하였고, 결제에 동의합니다.', style: TextStyle(fontSize: 15, color: Colors.black),),
                ),
              ),
            ),
            Checkbox(
              value: agreedToTerms,
              onChanged: (value) {
                setState(() {
                  agreedToTerms = value!;
                });
              },
            ),
          ],
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              if (!agreedToTerms) {
                // 필수항목 체크해주세요 알림
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('필수 항목'),
                      content: Text('필수 항목을 체크해주세요.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('닫기'),
                        ),
                      ],
                    );
                  },
                );
              } else {

                // 결제 처리를 위한 함수 호출 또는 네비게이션 추가
                setState(() {
                  totalPrice = calculateDiscountedPrice();
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Payment(
                      user: user, // 사용자 정보
                      //어느게 총 가격인지 몰라서 임시로 넣음
                      price: totalPrice,
                      productName: widget.productName, // 상품명
                      seller: widget.seller,
                    ),
                  ),
                );
              }
            },
            child: Text(
              '결제하기',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              primary: Color(0xFFFCAF58),
            ),
          ),
        ),
      ],
    ),
      ),
    );
  }

  int calculateDiscountedPrice() { // 할인된 가격 결제시 넘길 금액
    discountedPrice = int.parse(widget.price) - discountPercentage.toInt();
    print(discountedPrice);
    return discountedPrice;
  }
}