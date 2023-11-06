import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentCompletePage extends StatelessWidget {
  final Map<String, String> paymentResult;
  final String user;
  final int price;
  final String productName;
  final String seller;

  PaymentCompletePage({
    required this.paymentResult,
    required this.user,
    required this.price,
    required this.productName,
    required this.seller
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('결제 완료'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('결제가 완료되었습니다.'),
            SizedBox(height: 20),
            Text('결제 상태: ${paymentResult['imp_success']}'),
            Text('주문번호: ${paymentResult['merchant_uid']}'),
            Text('결제금액: $price'),
            ElevatedButton(
              onPressed: () async {

                String successStatus = paymentResult['imp_success'] ?? 'false';
                if (successStatus == 'true') {
                  // 결제가 성공한 경우
                  // Firestore 데이터베이스에 주문 내역 추가
                  await FirebaseFirestore.instance.collection('orders').add({
                    'user': user,
                    'productName': productName,
                    'price': price,
                    'orderNo' : paymentResult['merchant_uid'],
                    'status':  paymentResult['imp_success'],
                    'seller': seller,
                    'timestamp': FieldValue.serverTimestamp(),
                  });
                  // 메인 페이지로 이동
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } else {
                  // 결제가 실패한 경우
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }

              },
              child: Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
}
