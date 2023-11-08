import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
class PurchaseView extends StatefulWidget {
  final DocumentSnapshot document;
  PurchaseView({required this.document});
  @override
  _PurchaseViewState createState() => _PurchaseViewState(document: document);
}

class _PurchaseViewState extends State<PurchaseView> {
  final DocumentSnapshot document;
  _PurchaseViewState({required this.document});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "구매 내역",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFFFCAF58),
          elevation: 1.0,
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      body: Container(
        child: Column(
          children: [
            Text('구매번호 : ${data['orderNo']}'),
            Text(data['productName']),
            Text('판매자 : ${data['seller']}'),
            Text('가격 : ${data['price']}원'),
            Text('사용한 쿠폰 : ${data['cName']}원'),
            Text('구매일자 : ${DateFormat('yyyy-MM-dd').format(data['timestamp'].toDate())}'),
            Text(data['withdraw'] == 'N' ? '출금상태 : 출금전' : '출금상태 : 출금완료'),

          ],
        ),
      ),
    );
  }

}


