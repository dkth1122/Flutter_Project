import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/subBottomBar.dart';

import '../product/productView.dart';
class PurchaseView extends StatefulWidget {
  final DocumentSnapshot document;
  PurchaseView({required this.document});
  @override
  _PurchaseViewState createState() => _PurchaseViewState(document: document);
}

class _PurchaseViewState extends State<PurchaseView> {
  final DocumentSnapshot document;
  _PurchaseViewState({required this.document});


  //product컬렉션에서 이미지URL 가져오는법
  Future<String> getProductImageUrl(String pName) async {
    CollectionReference products = FirebaseFirestore.instance.collection('product');

    try {
      QuerySnapshot querySnapshot = await products.where('pName', isEqualTo: pName).get();

      if (querySnapshot.docs.isNotEmpty) {
        // querySnapshot에서 첫 번째 문서의 데이터를 가져옵니다.
        Map<String, dynamic> productData = (querySnapshot.docs.first.data() as Map<String, dynamic>);

        // productData에서 'ImageUrl' 키의 값을 가져와 반환합니다.
        return productData['iUrl'] ?? ''; // 만약 'ImageUrl' 값이 없으면 빈 문자열 반환
      } else {
        return ''; // 일치하는 상품이 없으면 빈 문자열 반환
      }
    } catch (e) {
      // 에러 처리
      print("Error fetching product image URL: $e");
      return ''; // 에러 발생 시 빈 문자열 반환
    }
  }







  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    Future<String> fetchImageUrl() async {
      try {
        String imageUrl = await getProductImageUrl(data['productName']);
        return imageUrl;
      } catch (e) {
        // 에러 처리
        print("Error fetching image URL: $e");
        return ''; // 에러 발생 시 빈 문자열 반환
      }
    }


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
            InfoBox("가격", '${NumberFormat('#,###').format(data['price'])}원'),
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
            Center(
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                          // 눌렸을 때의 색상
                          if (states.contains(MaterialState.pressed)) {
                            return Color(0xFFFCAF58);
                          }
                          // 기본 색상
                          return  Color(0xFFFCAF58);
                        },
                      ),
                    ),
                  onPressed: () async {
                        String imageUrl = await fetchImageUrl();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductView(
                              productName: data['productName'],
                              price: data['price'].toString(),
                              imageUrl: imageUrl,
                            ),
                          ),
                        );
                      },
                      child: Text("상품상세페이지로",style: TextStyle(fontSize: 20),)
            ))
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
