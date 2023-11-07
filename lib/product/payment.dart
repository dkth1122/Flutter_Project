import 'package:flutter/material.dart';

/* 아임포트 결제 모듈을 불러옵니다. */
import 'package:iamport_flutter/iamport_payment.dart';
/* 아임포트 결제 데이터 모델을 불러옵니다. */
import 'package:iamport_flutter/model/payment_data.dart';
import 'package:project_flutter/product/completePayment.dart';

class Payment extends StatelessWidget {
  final String user;
  final int price;
  final String productName;
  final String seller; // 판매자 정보 추가
  final String selectedCouponName;

  Payment({
    required this.user,
    required this.price,
    required this.productName,
    required this.seller, // 판매자 정보를 추가
    required this.selectedCouponName
  });


  @override
  Widget build(BuildContext context) {
    return IamportPayment(
      appBar: new AppBar(
        title: new Text('아임포트 결제'),
      ),
      /* 웹뷰 로딩 컴포넌트 */
      initialChild: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/dog1.PNG'),
              Padding(padding: EdgeInsets.symmetric(vertical: 15)),
              Text('잠시만 기다려주세요...', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
      /* [필수입력] 가맹점 식별코드 */
      userCode: 'imp36711884',
      /* [필수입력] 결제 데이터 */
      data: PaymentData(
          pg: 'tosspay',                                          // PG사
          payMethod: 'card',                                           // 결제수단
          name: '$productName 결제',                                  // 주문명
          merchantUid: 'mid_${DateTime.now().millisecondsSinceEpoch}', // 주문번호
          amount: price,                                               // 결제금액
          buyerName: '$user',                                           // 구매자 이름
          buyerTel: '01011112222',                                     // 구매자 연락처
          buyerEmail: 'skdus2995@naver.com',                             // 구매자 이메일
          buyerAddr: '테스트 주소',                         // 구매자 주소
          buyerPostcode: '12323',                                      // 구매자 우편번호
          appScheme: 'example',                                        // 앱 URL scheme
          cardQuota : [2,3]                                            //결제창 UI 내 할부개월수 제한
      ),
      /* [필수입력] 콜백 함수 */
      callback: (Map<String, String> result) {
        print(user);
        print(price);
        print(productName);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentCompletePage(
              paymentResult: result,
              user: user,        // 넘겨줄 user 데이터
              price: price,      // 넘겨줄 price 데이터
              productName: productName,
              seller: seller,// 넘겨줄 productName 데이터
                selectedCouponName : selectedCouponName

            ),
          ),
        );
      },
    );
  }
}