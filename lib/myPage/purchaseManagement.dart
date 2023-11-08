import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/myPage/purchaseView.dart';
class PurchaseManagement extends StatefulWidget {
  final String userId;

  const PurchaseManagement({required this.userId, Key? key}) : super(key: key);
  @override
  _PurchaseManagementState createState() => _PurchaseManagementState(userId:userId);
}
class PurchaseItem {
  final String orderNo;
  final String cName;
  final String productName;
  // final DateTime timestamp;
  final int price;

  PurchaseItem({
    required this.orderNo,
    required this.cName,
    required this.productName,
    // required this.timestamp,
    required this.price,
  });
}

class _PurchaseManagementState extends State<PurchaseManagement> {
  final String userId;
  String selectedWithdraw = "";
  String selectedCoupon = "";
  _PurchaseManagementState({required this.userId});
  List<String> optionsButton1 = [
    'UX기획',
    '웹',
    '커머스',
    '모바일',
    '프로그램',
    '트렌드',
    '데이터',
    '기타',];
  List<String> optionsButton3 = ["쿠폰사용", "쿠폰미사용"];
  List<String> optionsButton4 = ["출금전", "출금완료"];


  void _showInfoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      Navigator.of(context).pop(); // 모달 바텀 시트 닫기
                    },
                  ),
                  Text("구매관리 안내", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 12),
              Text("꼭 확인해주세요!", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "주문금액에 대한 세금계산서는 거래주체인 전문가가 직접발행하며, 세금계산서 발행 가능한 사업자전문가의 서비스 구매시에만 신청할 수 있습니다.",
              ),
            ],
          ),
        );
      },
    );
  }


  void _showFilterOptions(BuildContext context, List<String> options) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          children: options.map((option) {
            return ListTile(
              title: Text(option),
              onTap: () {
                if (optionsButton4.contains(option)) {
                  applyWithdrawFilter(option); // 선택한 출금여부를 전달하여 함수 호출
                }
                if (optionsButton3.contains(option)) {
                  applyCouponFilter(option); // 선택한 쿠폰여부를 전달하여 함수 호출
                }
              },
            );
          }).toList(),
        );
      },
    );
  }
  void applyWithdrawFilter(String option) {
    setState(() {
      if (option == "출금전") {
        selectedWithdraw = "N";
      } else if (option == "출금완료") {
        selectedWithdraw = "Y";
      } else {
        selectedWithdraw = ""; // 기본값 또는 다른 상황에 대한 처리
      }
    });
    Navigator.pop(context);
  }
void applyCouponFilter(String option) {
    setState(() {
      if (option == "쿠폰사용") {
        selectedCoupon = "Y";
      } else if (option == "쿠폰미사용") {
        selectedCoupon = "N";
      } else {
        selectedCoupon = ""; // 기본값 또는 다른 상황에 대한 처리
      }
    });
    Navigator.pop(context);
  }


  Widget _filterButton({
    IconData? icon, // Make the icon parameter nullable
    String? text, // Make the text parameter nullable
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon ?? Icons.arrow_drop_down),
      label: Text(text ?? "기본 텍스트"),
      style: ButtonStyle(
        side: MaterialStateProperty.all(BorderSide(width: 1.0, color:Color(0xFFFF8C42))),
        backgroundColor: MaterialStateProperty.all(Color(0xFFFF8C42) ),
        foregroundColor: MaterialStateProperty.all(Colors.white),
      ),
      onPressed: onPressed,
    );
  }


  Widget _listPurchase() {
    Query query = FirebaseFirestore.instance.collection("orders").where("user", isEqualTo: userId);

    if (selectedWithdraw == "N") {
      query = query.where("withdraw", isEqualTo: "N");
    } else if (selectedWithdraw == "Y") {
      query = query.where("withdraw", isEqualTo: "Y");
    }
    if (selectedCoupon == "N") {
      query = query.where("cName", isEqualTo: "사용하지 않음");
    } else if (selectedCoupon == "Y") {
      query = query.where("cName", isNotEqualTo: "사용하지 않음");
    }

    return StreamBuilder(
      stream: query.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
        if (!snap.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: snap.data!.docs.length,
          itemBuilder: (context, index) {
            DocumentSnapshot doc = snap.data!.docs[index];
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text('${data['productName']}'),
              subtitle: Column(
                children: [
                  _buildInfoBox("주문번호", data['orderNo']),
                  _buildInfoBox("사용쿠폰", data['cName']),
                ],
              ),
              trailing: Text('${data['price'].toString()}원'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PurchaseView(document: doc)),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInfoBox(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Divider(
            color: Colors.grey, // 선 색상
            thickness: 1, // 선의 두께
          ),
          Text(
            label,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey, // 라벨 텍스트 색상
            ),
          ),
        ],
      ),
    );
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "구매관리",
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
          actions: [
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                _showInfoModal(context);
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '검색',
                  prefixIcon: Icon(Icons.search),
                ),
                // Implement your search functionality here
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _filterButton(
                  icon: Icons.arrow_drop_down,
                  text: '출금상태',
                  onPressed: () {
                    _showFilterOptions(context, optionsButton4);
                  },
                ),
                SizedBox(width: 10), // 버튼 사이에 간격을 추가합니다
                _filterButton(
                  icon: Icons.arrow_drop_down,
                  text: '쿠폰여부',
                  onPressed: () {
                    _showFilterOptions(context, optionsButton3);
                  },
                ),
              ],
            ),
            _listPurchase()
          ],
      ),
    );
  }

}
