import 'package:flutter/material.dart';
import 'package:iamport_flutter/iamport_payment.dart';
import 'package:iamport_flutter/model/payment_data.dart';
import 'package:project_flutter/product/completePayment.dart';

class Payment extends StatelessWidget {
  final String user;
  final int price;
  final String productName;
  final String seller;
  final String selectedCouponName;

  Payment({
    required this.user,
    required this.price,
    required this.productName,
    required this.seller,
    required this.selectedCouponName,
  });

  @override
  Widget build(BuildContext context) {
    return IamportPayment(
      appBar: AppBar(
        title: Text(
          "결제 진행",
          style: TextStyle(
            color: Color(0xff424242),
            fontWeight: FontWeight.bold,
          ),
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
      initialChild: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png'),
              SizedBox(height: 50), // 공간을 띄워 이미지를 위로 이동
              CircularProgressIndicator(), // 동그라미 추가
            ],
          ),
        ),
      ),
      userCode: 'imp36711884',
      data: PaymentData(
        pg: 'tosspay',
        payMethod: 'card',
        name: '$productName 결제',
        merchantUid: 'mid_${DateTime.now().millisecondsSinceEpoch}',
        amount: price,
        buyerName: '$user',
        buyerTel: '01011112222',
        buyerEmail: 'skdus2995@naver.com',
        buyerAddr: '테스트 주소',
        buyerPostcode: '12323',
        appScheme: 'example',
        cardQuota: [2, 3],
      ),
      callback: (Map<String, String> result) {
        print(user);
        print(price);
        print(productName);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentCompletePage(
              paymentResult: result,
              user: user,
              price: price,
              productName: productName,
              seller: seller,
              selectedCouponName: selectedCouponName,
            ),
          ),
        );
      },
    );
  }
}
