import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class SalesManagementPage extends StatefulWidget {
  @override
  _SalesManagementPageState createState() => _SalesManagementPageState();
}
class PurchaseItem {
  final String title;
  final String product;
  final double price;

  PurchaseItem({
    required this.title,
    required this.product,
    required this.price,
  });
}

class _SalesManagementPageState extends State<SalesManagementPage> {
  List<String> optionsButton1 = [
    'UX기획',
    '웹',
    '커머스',
    '모바일',
    '프로그램',
    '트렌드',
    '데이터',
    '기타',];
  List<String> optionsButton2 = ["전체상태", "진행중", "주문취소", "구매확정"];


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
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
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

  void showDateRangePickerModal(BuildContext context) {
    DateTimeRange? selectedDateRange; // 모달 다이얼로그 내에서만 사용

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('날짜 범위 선택'),
              ElevatedButton(
                onPressed: () async {
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );

                  if (picked != null) {
                    selectedDateRange = picked; // 모달 다이얼로그 내에서 변수에 선택한 범위 저장
                  }
                },
                child: Text('날짜 범위 선택'),
              ),
              if (selectedDateRange != null) // 선택한 날짜 범위를 표시
                Text('선택한 시작 날짜: ${selectedDateRange!.start}\n선택한 종료 날짜: ${selectedDateRange!.end}'),
            ],
          ),
        );
      },
    );
  }

  Future<List<PurchaseItem>> fetchPurchaseList() async {
    try {
      CollectionReference purchases = FirebaseFirestore.instance.collection("purchases");
      QuerySnapshot snapshot = await purchases.get();

      List<PurchaseItem> purchaseList = snapshot.docs.map((doc) {
        return PurchaseItem(
          title: doc['title'] as String,
          product: doc['product'] as String,
          price: doc['price'] as double,
        );
      }).toList();

      return purchaseList;
    } catch (e) {
      // Handle any potential errors here
      return [];
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "판매관리",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF4E598C),
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
                text: '상품유형',
                onPressed: () {
                  _showFilterOptions(context, optionsButton1);
                },
              ),
              SizedBox(width: 10), // 버튼 사이에 간격을 추가합니다
              _filterButton(
                icon: Icons.arrow_drop_down,
                text: '주문상태',
                onPressed: () {
                  _showFilterOptions(context, optionsButton2);
                },
              ),
              SizedBox(width: 10), // 버튼 사이에 간격을 추가합니다
              _filterButton(
                  icon: Icons.arrow_drop_down,
                  text: '주문기간',
                  onPressed: () async {
                    showDateRangePickerModal(context);
                  }
              ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text("주문 1"),
                  subtitle: Text("상품 1"),
                  trailing: Text("가격: \$10"),
                ),
                ListTile(
                  title: Text("주문 2"),
                  subtitle: Text("상품 2"),
                  trailing: Text("가격: \$20"),
                ),
                // Additional order items
              ],
            ),
          ),
        ],
      ),
    );
  }

}
