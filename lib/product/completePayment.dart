import 'package:flutter/material.dart';

class PaymentCompletePage extends StatelessWidget {
  final Map<String, String> paymentResult;

  PaymentCompletePage({required this.paymentResult});

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
            Text('결제금액: ${paymentResult['amount']}'),
            // 기타 필요한 결제 결과 정보를 추가하세요
          ],
        ),
      ),
    );
  }
}
