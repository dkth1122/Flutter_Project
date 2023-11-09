import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/subBottomBar.dart';
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
          style: TextStyle(color: Color(0xff424242), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: IconThemeData(color: Color(0xff424242),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoBox("구매번호", data['orderNo']),
            InfoBox("상품명", data['productName']),
            InfoBox("판매자", data['seller']),
            InfoBox("가격", "${data['price']}원"),
            InfoBox("사용한 쿠폰", data['cName']),
            InfoBox(
              "구매일자",
              DateFormat('yyyy-MM-dd').format(data['timestamp'].toDate()),
            ),
            InfoBox(
              "출금상태",
              data['withdraw'] == 'N' ? '출금전' : '출금완료',
              textColor: data['withdraw'] == 'N' ? Color(0xFFFF8C42) : Color(0xFFFCAF58),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SubBottomBar(),
    );
  }
}

class InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;

  InfoBox(this.label, this.value, {this.textColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFFFF8C42),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
